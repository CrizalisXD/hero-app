-- ════════════════════════════════════════════════════════════════════
-- Hero — 0030_challenges_with_stats.sql
--
-- Phase 18 UX redesign feedback (competitor reference: "Лайв-челленджи"):
-- the new card / detail layout shows participant count and a live
-- countdown next to each challenge. The countdown is computed client-
-- side from `end_at`, but participant_count needs to come from the
-- server — there's no point loading every row of challenge_participants
-- on the client just to len() it.
--
-- This migration:
--   1. Extends list_system_challenges() and list_user_created_challenges()
--      to also return participants_count (aggregated subquery, gated on
--      joined / completed status so dropped-out users don't inflate it).
--   2. Adds get_challenge_stats(p_challenge_id) for the detail screen —
--      same number, but addressable without re-fetching the whole list.
--
-- DROP FUNCTION … is required for both list_* RPCs because the
-- RETURN TABLE column set changes; CREATE OR REPLACE doesn't allow that.
-- ════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.list_system_challenges();

CREATE FUNCTION public.list_system_challenges()
RETURNS TABLE(
  id                  uuid,
  challenge_type      text,
  metric_type         text,
  title_key           text,
  description_key     text,
  title_custom        text,
  description_custom  text,
  target_value        numeric,
  reward_xp           integer,
  start_at            timestamptz,
  end_at              timestamptz,
  participants_count  integer
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
           c.target_value, c.reward_xp, c.start_at, c.end_at,
           COALESCE((
             SELECT COUNT(*)::int
               FROM public.challenge_participants cp
              WHERE cp.challenge_id = c.id
                AND cp.status IN ('joined', 'completed')
           ), 0) AS participants_count
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


DROP FUNCTION IF EXISTS public.list_user_created_challenges();

CREATE FUNCTION public.list_user_created_challenges()
RETURNS TABLE(
  id                  uuid,
  challenge_type      text,
  metric_type         text,
  title_key           text,
  description_key     text,
  title_custom        text,
  description_custom  text,
  target_value        numeric,
  reward_xp           integer,
  start_at            timestamptz,
  end_at              timestamptz,
  participants_count  integer
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
           c.target_value, c.reward_xp, c.start_at, c.end_at,
           COALESCE((
             SELECT COUNT(*)::int
               FROM public.challenge_participants cp
              WHERE cp.challenge_id = c.id
                AND cp.status IN ('joined', 'completed')
           ), 0) AS participants_count
      FROM public.challenges c
     WHERE c.is_active = true
       AND c.created_by = v_user
     ORDER BY c.created_at DESC;
END $$;

REVOKE ALL   ON FUNCTION public.list_user_created_challenges() FROM public;
GRANT EXECUTE ON FUNCTION public.list_user_created_challenges() TO authenticated;


-- One-shot stats lookup for the detail screen. Cheap enough to call
-- when the user opens a challenge directly (e.g. from a notification)
-- without refetching the whole catalog.
CREATE OR REPLACE FUNCTION public.get_challenge_stats(p_challenge_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count int;
BEGIN
  SELECT COUNT(*)::int INTO v_count
    FROM public.challenge_participants
   WHERE challenge_id = p_challenge_id
     AND status IN ('joined', 'completed');

  RETURN jsonb_build_object(
    'participants_count', COALESCE(v_count, 0)
  );
END $$;

REVOKE ALL   ON FUNCTION public.get_challenge_stats(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.get_challenge_stats(UUID) TO authenticated;
