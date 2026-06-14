-- ════════════════════════════════════════════════════════════════════
-- Hero — 0028_recurring_tasks.sql
--
-- Makes recurring tasks actually recur. tasks.is_recurring and
-- tasks.recurrence (daily | weekly) have always been on the schema,
-- but nothing acted on them: completing a "чистить зубы" task once
-- removed it forever, forcing users to either re-create it daily or
-- model it as a habit (which polluted streak semantics).
--
-- Behaviour after this migration:
--   • complete_task, after awarding XP and unlocking achievements, checks
--     whether the just-completed task was recurring. If yes, it spawns
--     a fresh copy with due_at advanced by +1 day (daily) or +7 days
--     (weekly). Same title, category, XP reward, all the metadata.
--   • The new copy starts at is_done=false so it appears in tomorrow's
--     Today list automatically.
--   • Race guard: a partial unique index (user_id, title, due_at::date)
--     WHERE is_recurring prevents spawning two copies for the same
--     calendar day (e.g. if the user undoes + re-completes).
--
-- This is intentionally separate from Habits: tasks have no streak,
-- no daily-bonus pressure — just "remember to do X tomorrow too".
-- ════════════════════════════════════════════════════════════════════


-- Dedup is done inline inside complete_task (an EXISTS check before
-- the INSERT) — a partial UNIQUE INDEX would require an immutable
-- expression, and due_at::date on a timestamptz is not immutable
-- because the cast depends on session timezone.


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
  v_pre_ids         TEXT[];
  v_next_due_at     TIMESTAMPTZ;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT COALESCE(array_agg(achievement_id), '{}'::TEXT[])
    INTO v_pre_ids
    FROM public.user_achievements
   WHERE user_id = v_user_id;

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
  ON CONFLICT DO NOTHING;

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

  PERFORM public.reward_energy(v_user_id, 5);

  PERFORM public.check_and_unlock_achievements(
    v_user_id,
    'task_completed',
    jsonb_build_object('task_id', p_task_id, 'category', v_task.main_category)
  );

  -- ── Recurrence: spawn next instance ─────────────────────────────
  -- Daily / weekly windows are computed off the original due_at (so
  -- the user keeps their preferred time-of-day). For ad-hoc recurring
  -- tasks without a due_at we anchor to now().
  IF v_task.is_recurring AND v_task.recurrence IS NOT NULL THEN
    v_next_due_at := CASE v_task.recurrence
      WHEN 'daily'  THEN COALESCE(v_task.due_at, now()) + INTERVAL '1 day'
      WHEN 'weekly' THEN COALESCE(v_task.due_at, now()) + INTERVAL '7 days'
      ELSE NULL
    END;

    IF v_next_due_at IS NOT NULL THEN
      -- Dedup guard: only insert if a non-done copy for that calendar
      -- day doesn't already exist (e.g. user un-completed and then
      -- re-completed within the same day).
      IF NOT EXISTS (
        SELECT 1 FROM public.tasks t
         WHERE t.user_id = v_user_id
           AND t.title = v_task.title
           AND t.is_recurring = true
           AND t.is_done = false
           AND t.due_at::date = v_next_due_at::date
      ) THEN
        INSERT INTO public.tasks (
          user_id, goal_id, title, description,
          main_category, secondary_categories,
          difficulty, duration, importance,
          xp_reward, discipline_xp_reward,
          is_recurring, recurrence,
          due_at, due_date,
          is_done
        )
        VALUES (
          v_user_id, v_task.goal_id, v_task.title, v_task.description,
          v_task.main_category, v_task.secondary_categories,
          v_task.difficulty, v_task.duration, v_task.importance,
          v_task.xp_reward, v_task.discipline_xp_reward,
          true, v_task.recurrence,
          v_next_due_at, v_next_due_at::date,
          false
        );
      END IF;
    END IF;
  END IF;

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
           'id',              a.id,
           'title_key',       a.title_key,
           'description_key', a.description_key,
           'icon_key',        a.icon_key,
           'rarity',          a.rarity,
           'reward_xp',       a.reward_xp,
           'reward_coins',    a.reward_coins
         ) ORDER BY ua.unlocked_at), '[]'::jsonb)
    INTO v_unlocked
    FROM public.user_achievements ua
    JOIN public.achievements a ON a.id = ua.achievement_id
   WHERE ua.user_id = v_user_id
     AND NOT (ua.achievement_id = ANY (v_pre_ids));

  RETURN jsonb_build_object(
    'ok',                     true,
    'duplicate',              false,
    'task_id',                p_task_id,
    'category',               v_task.main_category,
    'category_xp',            v_xp,
    'discipline_xp',          v_discipline,
    'xp_total_gained',        v_xp_total,
    'character',              v_xp_result,
    'unlocked_achievements',  v_unlocked,
    'recurring_spawned',      v_task.is_recurring AND v_next_due_at IS NOT NULL
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_task(UUID) TO authenticated;
