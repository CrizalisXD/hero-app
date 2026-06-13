-- ════════════════════════════════════════════════════════════════════
-- Hero — 0023_list_public_challenges.sql
--
-- The Phase 14 list_system_challenges() RPC strictly filters by
-- challenge_type = 'system'. With seasonal + weekly seeds now in the
-- catalog (migration 0022), that filter hid the new public challenges
-- from the UI.
--
-- Two changes:
--   1. Re-shape the existing RPC to return EVERY active public-ish
--      challenge (system + seasonal + weekly) and to include the
--      challenge_type column so the client can group / chip-filter.
--   2. Add list_user_created_challenges() — challenges authored by
--      the current user via create_user_challenge.
-- ════════════════════════════════════════════════════════════════════

-- Drop the old signature first — Postgres refuses CREATE OR REPLACE
-- when the RETURN TABLE columns change.
DROP FUNCTION IF EXISTS public.list_system_challenges();

CREATE FUNCTION public.list_system_challenges()
RETURNS TABLE(
  id              uuid,
  challenge_type  text,
  metric_type     text,
  title_key       text,
  description_key text,
  title_custom    text,
  description_custom text,
  target_value    numeric,
  reward_xp       integer,
  start_at        timestamptz,
  end_at          timestamptz
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
    SELECT c.id, c.challenge_type, c.metric_type,
           c.title_key, c.description_key,
           c.title_custom, c.description_custom,
           c.target_value, c.reward_xp, c.start_at, c.end_at
      FROM public.challenges c
     WHERE c.is_active = true
       AND c.challenge_type IN ('system', 'seasonal', 'weekly')
       AND now() BETWEEN c.start_at AND c.end_at
     ORDER BY
       CASE c.challenge_type
         WHEN 'weekly'   THEN 0
         WHEN 'seasonal' THEN 1
         WHEN 'system'   THEN 2
         ELSE 3
       END,
       c.created_at;
END $$;

REVOKE ALL   ON FUNCTION public.list_system_challenges() FROM public;
GRANT EXECUTE ON FUNCTION public.list_system_challenges() TO authenticated;


CREATE OR REPLACE FUNCTION public.list_user_created_challenges()
RETURNS TABLE(
  id              uuid,
  challenge_type  text,
  metric_type     text,
  title_key       text,
  description_key text,
  title_custom    text,
  description_custom text,
  target_value    numeric,
  reward_xp       integer,
  start_at        timestamptz,
  end_at          timestamptz
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    SELECT c.id, c.challenge_type, c.metric_type,
           c.title_key, c.description_key,
           c.title_custom, c.description_custom,
           c.target_value, c.reward_xp, c.start_at, c.end_at
      FROM public.challenges c
     WHERE c.is_active = true
       AND c.created_by = v_user
     ORDER BY c.created_at DESC;
END $$;

REVOKE ALL   ON FUNCTION public.list_user_created_challenges() FROM public;
GRANT EXECUTE ON FUNCTION public.list_user_created_challenges() TO authenticated;
