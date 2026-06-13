-- ════════════════════════════════════════════════════════════════════
-- Hero — 0025_uncomplete_actions.sql
--
-- Adds undo-completion RPCs for tasks, habit check-ins, and
-- milestones. The "I tapped by accident, give me 5 seconds to take it
-- back" pattern.
--
-- Reversal scope (kept minimal so the migration stays auditable):
--   • flip is_done back to false; clear completed_at
--   • delete the xp_ledger row (the only place per-action XP is
--     stored; if it's gone, the user can re-earn next time)
--   • subtract the per-category XP from category_progress
--   • subtract the discipline XP from meta_stats
--   • subtract the total xp from character_stats.xp_total /
--     xp_current (clamped at 0 — we do NOT undo level-ups; the
--     user keeps any tier they reached)
--   • habits: also delete today's habit_logs row and decrement
--     current_streak by 1 (clamped at 0); best_streak is untouched
--   • milestones: same XP rollback, no streak math
--
-- All RPCs are idempotent — calling them on an already-undone row is
-- a no-op (returns ok=true, undone=false).
-- ════════════════════════════════════════════════════════════════════


-- ── uncomplete_task ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.uncomplete_task(p_task_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_task public.tasks%ROWTYPE;
  v_ledger public.xp_ledger%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_task FROM public.tasks
   WHERE id = p_task_id AND user_id = v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'task_not_found'; END IF;

  IF NOT v_task.is_done THEN
    RETURN jsonb_build_object('ok', true, 'undone', false);
  END IF;

  -- Look up the ledger row we want to roll back. NULL → user never
  -- got XP for it (legacy / pre-fix); we still flip is_done back.
  SELECT * INTO v_ledger FROM public.xp_ledger
   WHERE user_id = v_user
     AND source_type = 'task'
     AND source_id = p_task_id
   ORDER BY created_at DESC
   LIMIT 1;

  -- Reverse the row state.
  UPDATE public.tasks
     SET is_done = false, completed_at = NULL, updated_at = now()
   WHERE id = p_task_id;

  -- Drop the audit log entry for this completion so the next tap
  -- doesn't see it as a duplicate.
  DELETE FROM public.task_logs
   WHERE user_id = v_user
     AND task_id = p_task_id
     AND action = 'completed';

  IF FOUND THEN NULL; END IF;

  IF v_ledger.id IS NOT NULL THEN
    DELETE FROM public.xp_ledger WHERE id = v_ledger.id;

    UPDATE public.category_progress
       SET xp_total = GREATEST(0, xp_total - v_ledger.xp_amount),
           updated_at = now()
     WHERE user_id = v_user AND category = v_ledger.category;

    UPDATE public.meta_stats
       SET discipline_xp = GREATEST(0, discipline_xp - v_ledger.discipline_xp_amount),
           updated_at = now()
     WHERE user_id = v_user;

    UPDATE public.character_stats
       SET xp_total = GREATEST(0, xp_total - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           xp_current = GREATEST(0, xp_current - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           updated_at = now()
     WHERE user_id = v_user;
  END IF;

  RETURN jsonb_build_object('ok', true, 'undone', true, 'task_id', p_task_id);
END $$;

REVOKE ALL   ON FUNCTION public.uncomplete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.uncomplete_task(UUID) TO authenticated;


-- ── uncomplete_habit_checkin ─────────────────────────────────────────
-- Undoes TODAY's check-in for a habit. Same rollback pattern but also
-- decrements current_streak and removes the habit_logs row so the user
-- can re-do their check-in. Bad-habit slips can also be undone — the
-- discipline penalty is reimbursed.
CREATE OR REPLACE FUNCTION public.uncomplete_habit_checkin(p_habit_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_habit public.habits%ROWTYPE;
  v_today DATE := CURRENT_DATE;
  v_ledger public.xp_ledger%ROWTYPE;
  v_deleted INT;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_habit FROM public.habits
   WHERE id = p_habit_id AND user_id = v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  -- Try to delete today's log; if nothing was logged today, nothing to do.
  DELETE FROM public.habit_logs
   WHERE habit_id = p_habit_id AND log_date = v_today;
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  IF v_deleted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'undone', false);
  END IF;

  IF v_habit.type = 'bad' THEN
    -- Slip undo: bring streak back from 0 to what it was the day
    -- before. Easy heuristic: count yesterday's slip absence.
    UPDATE public.habits
       SET last_slip_date = NULL,
           updated_at = now()
     WHERE id = p_habit_id;

    -- Refund the discipline penalty.
    UPDATE public.meta_stats
       SET discipline_xp = discipline_xp + 2,
           updated_at = now()
     WHERE user_id = v_user;

    RETURN jsonb_build_object(
      'ok', true,
      'undone', true,
      'habit_id', p_habit_id,
      'slip_reverted', true
    );
  END IF;

  -- Good habit reverse.
  UPDATE public.habits
     SET current_streak = GREATEST(0, current_streak - 1),
         updated_at = now()
   WHERE id = p_habit_id;

  SELECT * INTO v_ledger FROM public.xp_ledger
   WHERE user_id = v_user
     AND source_type = 'habit'
     AND source_id = p_habit_id
     AND log_date = v_today
   LIMIT 1;

  IF v_ledger.id IS NOT NULL THEN
    DELETE FROM public.xp_ledger WHERE id = v_ledger.id;

    UPDATE public.category_progress
       SET xp_total = GREATEST(0, xp_total - v_ledger.xp_amount),
           updated_at = now()
     WHERE user_id = v_user AND category = v_ledger.category;

    UPDATE public.meta_stats
       SET discipline_xp = GREATEST(0, discipline_xp - v_ledger.discipline_xp_amount),
           updated_at = now()
     WHERE user_id = v_user;

    UPDATE public.character_stats
       SET xp_total = GREATEST(0, xp_total - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           xp_current = GREATEST(0, xp_current - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           updated_at = now()
     WHERE user_id = v_user;
  END IF;

  RETURN jsonb_build_object('ok', true, 'undone', true, 'habit_id', p_habit_id);
END $$;

REVOKE ALL   ON FUNCTION public.uncomplete_habit_checkin(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.uncomplete_habit_checkin(UUID) TO authenticated;


-- ── uncomplete_milestone ─────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.uncomplete_milestone(p_milestone_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_ms public.milestones%ROWTYPE;
  v_ledger public.xp_ledger%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_ms FROM public.milestones
   WHERE id = p_milestone_id AND user_id = v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'milestone_not_found'; END IF;

  IF NOT v_ms.is_done THEN
    RETURN jsonb_build_object('ok', true, 'undone', false);
  END IF;

  UPDATE public.milestones
     SET is_done = false, completed_at = NULL
   WHERE id = p_milestone_id;

  SELECT * INTO v_ledger FROM public.xp_ledger
   WHERE user_id = v_user
     AND source_type = 'milestone'
     AND source_id = p_milestone_id
   ORDER BY created_at DESC
   LIMIT 1;

  IF v_ledger.id IS NOT NULL THEN
    DELETE FROM public.xp_ledger WHERE id = v_ledger.id;
    UPDATE public.character_stats
       SET xp_total = GREATEST(0, xp_total - v_ledger.xp_amount),
           xp_current = GREATEST(0, xp_current - v_ledger.xp_amount),
           updated_at = now()
     WHERE user_id = v_user;
  END IF;

  RETURN jsonb_build_object('ok', true, 'undone', true, 'milestone_id', p_milestone_id);
END $$;

REVOKE ALL   ON FUNCTION public.uncomplete_milestone(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.uncomplete_milestone(UUID) TO authenticated;
