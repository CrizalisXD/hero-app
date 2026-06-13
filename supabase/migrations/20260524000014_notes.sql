-- ════════════════════════════════════════════════════════════════════
-- Hero — 0017_notes.sql  (TZ §"Notes privacy")
--
-- Adds the Notes feature:
--   • notes table (id, user_id, title?, content, visibility, …)
--   • visibility enum: 'private' (default) | 'ai_allowed'
--   • RLS: every user only sees their own rows
--   • consent key ai_can_use_notes — master switch for AI access
--
-- AI gating happens in the ai-chat Edge Function, not at DB level:
--   - private notes are NEVER fetched in chat context (no DB filter
--     needed beyond visibility check in the function)
--   - ai_allowed notes are fetched ONLY when user has consent
--     ai_can_use_notes = true
--
-- Migration is idempotent so re-running is safe.
-- ════════════════════════════════════════════════════════════════════

-- 1) ── Visibility enum ──────────────────────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_type WHERE typname = 'note_visibility'
  ) THEN
    CREATE TYPE public.note_visibility AS ENUM ('private', 'ai_allowed');
  END IF;
END $$;

-- 2) ── notes table ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT,
  content     TEXT NOT NULL DEFAULT '',
  visibility  public.note_visibility NOT NULL DEFAULT 'private',
  is_deleted  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notes_user_visibility
  ON public.notes (user_id, visibility) WHERE is_deleted = false;

CREATE INDEX IF NOT EXISTS idx_notes_user_updated
  ON public.notes (user_id, updated_at DESC) WHERE is_deleted = false;

DROP TRIGGER IF EXISTS tg_notes_updated_at ON public.notes;
CREATE TRIGGER tg_notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 3) ── RLS ──────────────────────────────────────────────────────────
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_notes_own ON public.notes;
CREATE POLICY p_notes_own ON public.notes
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 4) ── Consent key seed ─────────────────────────────────────────────
-- The consent row itself is created on demand by the client, but if any
-- other migration seeded a default set, register the key here too.
-- (user_consents has UNIQUE(user_id, consent_key) so re-insert per user
-- is harmless — Dart-side just writes 'ai_can_use_notes' rows.)

-- 5) ── Helper RPC: list_notes ───────────────────────────────────────
-- Returns visible notes for the current user, newest first, with optional
-- visibility filter. RLS already restricts to own rows; the RPC just
-- removes is_deleted noise from the client.
CREATE OR REPLACE FUNCTION public.list_notes(
  p_visibility public.note_visibility DEFAULT NULL,
  p_limit      INT DEFAULT 100
)
RETURNS SETOF public.notes
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT n.*
    FROM public.notes n
   WHERE n.user_id = auth.uid()
     AND n.is_deleted = false
     AND (p_visibility IS NULL OR n.visibility = p_visibility)
   ORDER BY n.updated_at DESC
   LIMIT GREATEST(1, LEAST(p_limit, 500));
$$;

REVOKE ALL   ON FUNCTION public.list_notes(public.note_visibility, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.list_notes(public.note_visibility, INT) TO authenticated;

-- 6) ── Soft-delete RPC ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.delete_note(p_note_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_rows    INT;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.notes
     SET is_deleted = true,
         updated_at = now()
   WHERE id = p_note_id
     AND user_id = v_user_id
     AND is_deleted = false;

  GET DIAGNOSTICS v_rows = ROW_COUNT;

  RETURN jsonb_build_object('ok', v_rows > 0, 'note_id', p_note_id);
END $$;

REVOKE ALL   ON FUNCTION public.delete_note(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.delete_note(UUID) TO authenticated;
