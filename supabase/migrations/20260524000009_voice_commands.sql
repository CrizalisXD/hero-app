-- ════════════════════════════════════════════════════════════════════
-- Hero — 0011_voice_commands.sql  (Phase 16)
--
-- Adds:
--   - voice_command_logs — audit log of every Siri/voice intent
--   - goal_drafts        — TZ §43.5: Siri can only DRAFT goals; user
--                          must confirm in Hero before they go live.
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.voice_command_logs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  platform       TEXT NOT NULL CHECK (platform IN ('siri','android_assistant','in_app_voice')),
  intent_name    TEXT NOT NULL,
  transcript     TEXT,
  status         TEXT NOT NULL CHECK (status IN ('success','failed','needs_confirmation')),
  result_payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_vcl_user_created
  ON public.voice_command_logs (user_id, created_at DESC);
ALTER TABLE public.voice_command_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_vcl_own ON public.voice_command_logs;
CREATE POLICY p_vcl_own ON public.voice_command_logs
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Goal drafts created by Siri (TZ §43.5 — never auto-commit a goal)
CREATE TABLE IF NOT EXISTS public.goal_drafts (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  source      TEXT NOT NULL DEFAULT 'siri' CHECK (source IN ('siri','manual')),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  consumed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_gd_user_open
  ON public.goal_drafts (user_id, consumed_at) WHERE consumed_at IS NULL;
ALTER TABLE public.goal_drafts ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_gd_own ON public.goal_drafts;
CREATE POLICY p_gd_own ON public.goal_drafts
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
