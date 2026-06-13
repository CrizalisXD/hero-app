-- ════════════════════════════════════════════════════════════════════
-- Hero — 0026_hotfix_get_today_health.sql
--
-- get_today_health() declares a RETURN TABLE column named last_sync_at
-- and then, in the body, references `last_sync_at` again unqualified
-- inside a subquery against user_integrations (which has its own
-- last_sync_at column). Postgres can't tell which one we meant:
--
--   PostgrestException: column reference "last_sync_at" is ambiguous
--   42702: It could refer to either a PL/pgSQL variable or a table
--   column.
--
-- This blew up the Health screen (user can't open Настройки → Здоровье).
--
-- Fix: table-qualify the column in the subquery so the resolver
-- chooses the user_integrations row over the OUT parameter. Drop the
-- function first because RETURN TABLE shape is unchanged but Postgres
-- can be finicky about CREATE OR REPLACE on PL/pgSQL bodies with new
-- planner hints.
-- ════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.get_today_health();

CREATE FUNCTION public.get_today_health()
RETURNS TABLE (
  steps           INT,
  distance_meters NUMERIC,
  workouts_count  INT,
  last_sync_at    TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    WITH today AS (
      SELECT COALESCE(SUM(s.steps), 0)::INT          AS steps,
             COALESCE(SUM(s.distance_meters), 0)     AS distance_meters,
             COALESCE(SUM(s.workouts_count), 0)::INT AS workouts_count
        FROM public.health_daily_summaries s
       WHERE s.user_id = v_me AND s.date = CURRENT_DATE
    )
    SELECT today.steps,
           today.distance_meters,
           today.workouts_count,
           (SELECT MAX(ui.last_sync_at)
              FROM public.user_integrations ui
             WHERE ui.user_id = v_me
               AND ui.provider IN ('apple_health','health_connect'))
      FROM today;
END $$;

REVOKE ALL   ON FUNCTION public.get_today_health() FROM public;
GRANT EXECUTE ON FUNCTION public.get_today_health() TO authenticated;
