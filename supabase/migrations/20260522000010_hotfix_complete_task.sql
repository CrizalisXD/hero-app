-- ════════════════════════════════════════════════════════════════════
-- Hero — 20260522000010_hotfix_complete_task.sql
--
-- Fixes applied (all idempotent):
--   1. tasks.due_at  — add TIMESTAMPTZ column + index + backfill
--   2. complete_task — ON CONFLICT DO NOTHING (was: ON CONSTRAINT)
--   3. complete_habit_checkin — same fix
--   4. categories / feature_flags — enable RLS, add SELECT policy
--
-- Apply in Supabase → SQL Editor (or `supabase db push`).
-- ════════════════════════════════════════════════════════════════════


-- ── 1. tasks.due_at ───────────────────────────────────────────────
-- Due-at is a precision timestamptz field. due_date (DATE) is kept
-- for backward compatibility; due_at takes priority when set.

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS due_at TIMESTAMPTZ;

-- Backfill: tasks that already have a due_date get due_at at noon UTC.
UPDATE public.tasks
  SET due_at = (due_date::timestamp + INTERVAL '12 hours') AT TIME ZONE 'UTC'
WHERE due_at IS NULL
  AND due_date IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_tasks_user_due_at
  ON public.tasks (user_id, due_at)
  WHERE due_at IS NOT NULL;


-- ── 2. complete_task ──────────────────────────────────────────────
-- Root cause: the initial migration creates uq_xp_ledger_replay as
--   CREATE UNIQUE INDEX  (an index, not a named CONSTRAINT)
-- but the RPC used:
--   ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay  ← requires a CONSTRAINT
-- PostgreSQL error 42704 ("constraint does not exist").
--
-- Fix: switch to ON CONFLICT DO NOTHING, which works with both
-- UNIQUE INDEXes and named CONSTRAINTs.

CREATE OR REPLACE FUNCTION public.complete_task(p_task_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id       UUID := auth.uid();
  v_task          public.tasks%ROWTYPE;
  v_xp            INT;
  v_discipline    INT;
  v_xp_total      INT;
  v_xp_result     JSONB;
  v_ledger_inserted INT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_task
  FROM public.tasks
  WHERE id = p_task_id AND user_id = v_user_id
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'task_not_found'; END IF;

  -- Already completed → idempotent return (no double-XP).
  IF v_task.is_done THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

  v_xp       := v_task.xp_reward;
  v_discipline := v_task.discipline_xp_reward;
  v_xp_total  := v_xp + v_discipline;

  -- Guard against replay: insert into ledger; if the row already exists
  -- (same user+source_type+source_id+log_date) just skip silently.
  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'task', p_task_id, v_task.main_category, v_xp, v_discipline, CURRENT_DATE)
  ON CONFLICT DO NOTHING;                          -- ← fixed (was: ON CONSTRAINT)

  GET DIAGNOSTICS v_ledger_inserted = ROW_COUNT;

  -- Ledger row already existed → mark done but do not award XP again.
  IF v_ledger_inserted = 0 THEN
    UPDATE public.tasks
      SET is_done = true, completed_at = now(), updated_at = now()
    WHERE id = p_task_id;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

  -- Mark task done.
  UPDATE public.tasks
    SET is_done = true, completed_at = now(), updated_at = now()
  WHERE id = p_task_id;

  -- Audit log.
  INSERT INTO public.task_logs (user_id, task_id, action, xp_earned)
  VALUES (v_user_id, p_task_id, 'completed', v_xp_total);

  -- Category XP.
  UPDATE public.category_progress
    SET xp_total = xp_total + v_xp,
        level    = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1),
        updated_at = now()
  WHERE user_id = v_user_id AND category = v_task.main_category;

  -- Meta stats.
  UPDATE public.meta_stats
    SET discipline_xp   = discipline_xp + v_discipline,
        last_active_date = CURRENT_DATE,
        updated_at       = now()
  WHERE user_id = v_user_id;

  -- Character level-up.
  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);

  RETURN jsonb_build_object(
    'ok',           true,
    'duplicate',    false,
    'task_id',      p_task_id,
    'category',     v_task.main_category,
    'category_xp',  v_xp,
    'discipline_xp', v_discipline,
    'xp_total_gained', v_xp_total,
    'character',    v_xp_result
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_task(UUID) TO authenticated;


-- ── 3. complete_habit_checkin ────────────────────────────────────
-- Same ON CONFLICT fix as complete_task.

CREATE OR REPLACE FUNCTION public.complete_habit_checkin(p_habit_id UUID, p_value INT DEFAULT 1)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id       UUID := auth.uid();
  v_habit         public.habits%ROWTYPE;
  v_today         DATE := CURRENT_DATE;
  v_yesterday     DATE := CURRENT_DATE - INTERVAL '1 day';
  v_was_yesterday BOOLEAN;
  v_new_streak    INT;
  v_xp            INT;
  v_discipline    INT;
  v_xp_total      INT;
  v_xp_result     JSONB;
  v_inserted      INT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_habit
  FROM public.habits
  WHERE id = p_habit_id AND user_id = v_user_id
  FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  INSERT INTO public.habit_logs (habit_id, user_id, log_date, value, xp_earned)
  VALUES (p_habit_id, v_user_id, v_today, p_value, v_habit.xp_reward + v_habit.discipline_xp_reward)
  ON CONFLICT (habit_id, log_date) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;

  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;

  -- Streak logic.
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

  v_xp       := v_habit.xp_reward;
  v_discipline := v_habit.discipline_xp_reward;
  v_xp_total  := v_xp + v_discipline;

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'habit', p_habit_id, v_habit.main_category, v_xp, v_discipline, v_today)
  ON CONFLICT DO NOTHING;                          -- ← fixed (was: ON CONSTRAINT)

  -- Category XP.
  UPDATE public.category_progress
    SET xp_total = xp_total + v_xp,
        level    = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1),
        updated_at = now()
  WHERE user_id = v_user_id AND category = v_habit.main_category;

  -- Meta stats.
  UPDATE public.meta_stats
    SET discipline_xp    = discipline_xp + v_discipline,
        current_streak   = GREATEST(current_streak, v_new_streak),
        best_streak      = GREATEST(best_streak, v_new_streak),
        last_active_date = v_today,
        updated_at       = now()
  WHERE user_id = v_user_id;

  -- Character level-up.
  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);

  RETURN jsonb_build_object(
    'ok',            true,
    'duplicate',     false,
    'habit_id',      p_habit_id,
    'category',      v_habit.main_category,
    'category_xp',   v_xp,
    'discipline_xp', v_discipline,
    'current_streak', v_new_streak,
    'character',     v_xp_result
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_habit_checkin(UUID, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_habit_checkin(UUID, INT) TO authenticated;


-- ── 4. RLS for categories & feature_flags ────────────────────────
-- These are read-only lookup tables. Without RLS policies the
-- Supabase anon/authenticated roles may be blocked depending on
-- the project's default grants. Make it explicit.

ALTER TABLE public.categories    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_flags ENABLE ROW LEVEL SECURITY;

-- Drop any leftover policies before recreating (idempotent).
DROP POLICY IF EXISTS p_categories_read    ON public.categories;
DROP POLICY IF EXISTS p_feature_flags_read ON public.feature_flags;

-- Any authenticated user may read categories (static lookup data).
CREATE POLICY p_categories_read ON public.categories
  FOR SELECT TO authenticated USING (true);

-- Any authenticated user may read feature flags.
CREATE POLICY p_feature_flags_read ON public.feature_flags
  FOR SELECT TO authenticated USING (true);


-- ════════════════════════════════════════════════════════════════════
-- END OF HOTFIX
-- ════════════════════════════════════════════════════════════════════
