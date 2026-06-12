-- ════════════════════════════════════════════════════════════════════
-- Hero — 0014_hotfix_complete_task_redux.sql
--
-- The Phase 5 hotfix (20260522000010) replaced the broken
--   ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay
-- (the unique index isn't a named CONSTRAINT) with
--   ON CONFLICT DO NOTHING.
--
-- Phase 12 (20260524000004_achievements.sql) then re-defined both
-- complete_task and complete_habit_checkin to add achievement hooks —
-- and accidentally restored the broken ON CONSTRAINT syntax. Effect:
-- every task / habit completion on cloud throws 42704
-- ("constraint uq_xp_ledger_replay does not exist") → 500 to the
-- client → the UI's catch path triggers, no XP, no progress, no
-- achievement unlock.
--
-- This migration re-applies the ON CONFLICT DO NOTHING fix while
-- preserving the achievements integration. No behavior change beyond
-- making the function executable.
-- ════════════════════════════════════════════════════════════════════

-- ── 1. complete_task ─────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.complete_task(p_task_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id         UUID := auth.uid();
  v_task            public.tasks%ROWTYPE;
  v_xp              INT;
  v_discipline      INT;
  v_xp_total        INT;
  v_xp_result       JSONB;
  v_ledger_inserted INT;
  v_unlocked        JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO v_task FROM public.tasks
   WHERE id = p_task_id AND user_id = v_user_id
   FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'task_not_found'; END IF;

  IF v_task.is_done THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

  v_xp         := v_task.xp_reward;
  v_discipline := v_task.discipline_xp_reward;
  v_xp_total   := v_xp + v_discipline;

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'task', p_task_id, v_task.main_category, v_xp, v_discipline, CURRENT_DATE)
  ON CONFLICT DO NOTHING;                          -- ← restored fix

  GET DIAGNOSTICS v_ledger_inserted = ROW_COUNT;
  IF v_ledger_inserted = 0 THEN
    UPDATE public.tasks
       SET is_done = true, completed_at = now(), updated_at = now()
     WHERE id = p_task_id;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

  UPDATE public.tasks
     SET is_done = true, completed_at = now(), updated_at = now()
   WHERE id = p_task_id;

  INSERT INTO public.task_logs (user_id, task_id, action, xp_earned)
  VALUES (v_user_id, p_task_id, 'completed', v_xp_total);

  UPDATE public.category_progress
     SET xp_total = xp_total + v_xp,
         level    = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1),
         updated_at = now()
   WHERE user_id = v_user_id AND category = v_task.main_category;

  UPDATE public.meta_stats
     SET discipline_xp     = discipline_xp + v_discipline,
         last_active_date  = CURRENT_DATE,
         updated_at        = now()
   WHERE user_id = v_user_id;

  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);

  v_unlocked := public.check_and_unlock_achievements(
    v_user_id,
    'task_completed',
    jsonb_build_object('task_id', p_task_id, 'category', v_task.main_category)
  );

  RETURN jsonb_build_object(
    'ok',                     true,
    'duplicate',              false,
    'task_id',                p_task_id,
    'category',               v_task.main_category,
    'category_xp',            v_xp,
    'discipline_xp',          v_discipline,
    'xp_total_gained',        v_xp_total,
    'character',              v_xp_result,
    'unlocked_achievements',  v_unlocked
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_task(UUID) TO authenticated;


-- ── 2. complete_habit_checkin ────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.complete_habit_checkin(p_habit_id UUID, p_value INT DEFAULT 1)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id        UUID := auth.uid();
  v_habit          public.habits%ROWTYPE;
  v_today          DATE := CURRENT_DATE;
  v_yesterday      DATE := CURRENT_DATE - INTERVAL '1 day';
  v_was_yesterday  BOOLEAN;
  v_new_streak     INT;
  v_xp             INT;
  v_discipline     INT;
  v_xp_total       INT;
  v_xp_result      JSONB;
  v_inserted       INT;
  v_unlocked       JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO v_habit FROM public.habits
   WHERE id = p_habit_id AND user_id = v_user_id
   FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  INSERT INTO public.habit_logs
    (habit_id, user_id, log_date, value, xp_earned)
  VALUES
    (p_habit_id, v_user_id, v_today, p_value,
     v_habit.xp_reward + v_habit.discipline_xp_reward)
  ON CONFLICT (habit_id, log_date) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM public.habit_logs
     WHERE habit_id = p_habit_id AND log_date = v_yesterday
  ) INTO v_was_yesterday;

  v_new_streak := CASE WHEN v_was_yesterday THEN v_habit.current_streak + 1 ELSE 1 END;

  UPDATE public.habits
     SET current_streak = v_new_streak,
         best_streak    = GREATEST(best_streak, v_new_streak),
         updated_at     = now()
   WHERE id = p_habit_id;

  v_xp         := v_habit.xp_reward;
  v_discipline := v_habit.discipline_xp_reward;
  v_xp_total   := v_xp + v_discipline;

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'habit', p_habit_id, v_habit.main_category, v_xp, v_discipline, v_today)
  ON CONFLICT DO NOTHING;                          -- ← restored fix

  UPDATE public.category_progress
     SET xp_total = xp_total + v_xp,
         level    = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1),
         updated_at = now()
   WHERE user_id = v_user_id AND category = v_habit.main_category;

  UPDATE public.meta_stats
     SET discipline_xp    = discipline_xp + v_discipline,
         current_streak   = GREATEST(current_streak, v_new_streak),
         best_streak      = GREATEST(best_streak, v_new_streak),
         last_active_date = v_today,
         updated_at       = now()
   WHERE user_id = v_user_id;

  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);

  v_unlocked := public.check_and_unlock_achievements(
    v_user_id,
    'habit_completed',
    jsonb_build_object('habit_id', p_habit_id, 'streak', v_new_streak)
  );

  RETURN jsonb_build_object(
    'ok',                     true,
    'duplicate',              false,
    'habit_id',               p_habit_id,
    'category',               v_habit.main_category,
    'category_xp',            v_xp,
    'discipline_xp',          v_discipline,
    'current_streak',         v_new_streak,
    'character',              v_xp_result,
    'unlocked_achievements',  v_unlocked
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_habit_checkin(UUID, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_habit_checkin(UUID, INT) TO authenticated;
