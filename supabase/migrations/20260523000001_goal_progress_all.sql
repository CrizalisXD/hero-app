-- goal_progress_me() — no args, returns progress for ALL active goals of the
-- current user. Called by GoalsNotifier to populate the goals list screen.

CREATE OR REPLACE FUNCTION public.goal_progress_me()
RETURNS TABLE (
  goal_id          UUID,
  tasks_done       INT,
  tasks_total      INT,
  milestones_done  INT,
  milestones_total INT
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  RETURN QUERY
    SELECT
      g.id                                                           AS goal_id,
      COALESCE(COUNT(t.id) FILTER (WHERE t.is_done = true), 0)::INT AS tasks_done,
      COALESCE(COUNT(t.id), 0)::INT                                  AS tasks_total,
      COALESCE(COUNT(m.id) FILTER (WHERE m.is_done = true), 0)::INT AS milestones_done,
      COALESCE(COUNT(m.id), 0)::INT                                  AS milestones_total
    FROM public.goals g
    LEFT JOIN public.tasks      t ON t.goal_id = g.id
    LEFT JOIN public.milestones m ON m.goal_id = g.id
    WHERE g.user_id    = v_user_id
      AND g.is_deleted = false
    GROUP BY g.id;
END;
$$;

REVOKE ALL ON FUNCTION public.goal_progress_me() FROM public;
GRANT EXECUTE ON FUNCTION public.goal_progress_me() TO authenticated;
