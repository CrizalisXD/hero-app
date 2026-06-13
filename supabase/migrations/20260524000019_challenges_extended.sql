-- ════════════════════════════════════════════════════════════════════
-- Hero — 0022_challenges_extended.sql
--
-- Expands the Phase 14 challenges feature into a real "Challenges" tab:
--   1. Adds two new challenge_type values:
--        seasonal — bounded by start/end (e.g. summer 2026, new year)
--        weekly   — repeating windows handled by a cron job (later)
--      Previous values (`system`, `user`, `friend`) keep working.
--   2. Adds a created_by UUID column so user/friend challenges can be
--      attributed and listed under "My challenges".
--   3. Seeds: 2 weekly (active this calendar week), 1 seasonal (summer).
--   4. RPC create_user_challenge(...) — minimum needed for a user to
--      author their own challenge. Friend invites stay deferred to v1.1.
--
-- Out of scope here (will need a separate pass once UX direction is
-- clearer):
--   • automatic weekly regeneration via cron / Edge Function
--   • friend invitations + accept/decline flow
--   • leaderboards
-- ════════════════════════════════════════════════════════════════════

-- 1) ── Extend challenge_type CHECK ───────────────────────────────────
ALTER TABLE public.challenges
  DROP CONSTRAINT IF EXISTS challenges_challenge_type_check;

ALTER TABLE public.challenges
  ADD CONSTRAINT challenges_challenge_type_check
  CHECK (challenge_type = ANY (ARRAY[
    'system'::text,
    'seasonal'::text,
    'weekly'::text,
    'user'::text,
    'friend'::text
  ]));


-- 1b) ── Allow nullable title_key/description_key for user-created ────
-- Phase 14 forced both to NOT NULL because every system seed had an
-- ARB key. User-authored challenges supply title_custom instead, so
-- we relax the column NULL and add a "one of them is set" CHECK.
ALTER TABLE public.challenges
  ALTER COLUMN title_key DROP NOT NULL,
  ALTER COLUMN description_key DROP NOT NULL;

ALTER TABLE public.challenges
  DROP CONSTRAINT IF EXISTS challenges_title_present_check;
ALTER TABLE public.challenges
  ADD CONSTRAINT challenges_title_present_check
  CHECK (title_key IS NOT NULL OR title_custom IS NOT NULL);


-- 2) ── created_by ────────────────────────────────────────────────────
ALTER TABLE public.challenges
  ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES public.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_challenges_created_by
  ON public.challenges (created_by)
  WHERE created_by IS NOT NULL;


-- 3) ── Seed: weekly + seasonal examples ──────────────────────────────
-- Weekly windows are "this calendar week (Mon-Sun)".
-- Using DATE_TRUNC('week', CURRENT_DATE) gives this week's Monday.
INSERT INTO public.challenges (
  id, challenge_type, metric_type, title_key, description_key,
  start_at, end_at, target_value, reward_xp, is_public, is_active
) VALUES
  (
    '22222222-2222-2222-2222-200000000001'::uuid,
    'weekly', 'count',
    'challengeWeeklyTasksTitle', 'challengeWeeklyTasksBody',
    DATE_TRUNC('week', CURRENT_DATE)::TIMESTAMPTZ,
    (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days')::TIMESTAMPTZ,
    10, 100, true, true
  ),
  (
    '22222222-2222-2222-2222-200000000002'::uuid,
    'weekly', 'activity_day',
    'challengeWeeklyActiveDaysTitle', 'challengeWeeklyActiveDaysBody',
    DATE_TRUNC('week', CURRENT_DATE)::TIMESTAMPTZ,
    (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days')::TIMESTAMPTZ,
    5, 80, true, true
  )
ON CONFLICT (id) DO UPDATE SET
  start_at = EXCLUDED.start_at,
  end_at   = EXCLUDED.end_at;

-- Seasonal: "Summer 2026" running June 1 – August 31.
INSERT INTO public.challenges (
  id, challenge_type, metric_type, title_key, description_key,
  start_at, end_at, target_value, reward_xp, is_public, is_active
) VALUES (
  '33333333-3333-3333-3333-300000000001'::uuid,
  'seasonal', 'count',
  'challengeSummer2026Title', 'challengeSummer2026Body',
  '2026-06-01 00:00:00+00'::TIMESTAMPTZ,
  '2026-08-31 23:59:59+00'::TIMESTAMPTZ,
  100, 500, true, true
)
ON CONFLICT (id) DO NOTHING;


-- 4) ── RPC: create_user_challenge ───────────────────────────────────
-- Lets a signed-in user author their own challenge. The challenge is
-- private by default (is_public=false) so it shows up only in their
-- "My challenges" tab — friend invites come later.
--
-- Constraints enforced server-side:
--   • title length 2..100
--   • end_at > now() + 1 day and within 365 days
--   • target_value > 0
--   • metric_type in the allowed set
CREATE OR REPLACE FUNCTION public.create_user_challenge(
  p_title         TEXT,
  p_description   TEXT,
  p_metric_type   TEXT,
  p_target_value  NUMERIC,
  p_end_at        TIMESTAMPTZ,
  p_reward_xp     INT DEFAULT 50
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_id UUID := gen_random_uuid();
  v_title TEXT;
  v_now TIMESTAMPTZ := now();
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  v_title := trim(COALESCE(p_title, ''));
  IF length(v_title) < 2 OR length(v_title) > 100 THEN
    RAISE EXCEPTION 'invalid_title';
  END IF;

  IF p_end_at IS NULL OR p_end_at < v_now + INTERVAL '1 day' THEN
    RAISE EXCEPTION 'invalid_end_at_too_soon';
  END IF;
  IF p_end_at > v_now + INTERVAL '365 days' THEN
    RAISE EXCEPTION 'invalid_end_at_too_far';
  END IF;

  IF p_target_value IS NULL OR p_target_value <= 0 THEN
    RAISE EXCEPTION 'invalid_target_value';
  END IF;

  IF p_metric_type NOT IN
     ('streak','count','distance','xp','habit','category','activity_day') THEN
    RAISE EXCEPTION 'invalid_metric_type';
  END IF;

  INSERT INTO public.challenges (
    id, challenge_type, metric_type,
    title_custom, description_custom,
    start_at, end_at, target_value, reward_xp,
    is_public, is_active, created_by
  )
  VALUES (
    v_id, 'user', p_metric_type,
    v_title,
    NULLIF(trim(COALESCE(p_description, '')), ''),
    v_now, p_end_at, p_target_value,
    LEAST(GREATEST(COALESCE(p_reward_xp, 50), 0), 500),
    false, true, v_user
  );

  RETURN jsonb_build_object(
    'ok', true,
    'challenge_id', v_id
  );
END $$;

REVOKE ALL   ON FUNCTION public.create_user_challenge(TEXT, TEXT, TEXT, NUMERIC, TIMESTAMPTZ, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.create_user_challenge(TEXT, TEXT, TEXT, NUMERIC, TIMESTAMPTZ, INT) TO authenticated;
