-- ════════════════════════════════════════════════════════════════════
-- Hero — 0029_recurring_tasks_in_place.sql
--
-- Reverses the "spawn a fresh row per occurrence" approach from
-- migration 0028 in favour of the iOS Reminders pattern: ONE row per
-- recurring task forever, with due_at shifted forward on each
-- completion.
--
-- Why the rewrite (user feedback, day after the first ship):
--   • The duplicate-spawn approach grew the tasks table by one row
--     per recurrence cycle (≈365 rows/year for a daily task), which
--     hurts list-query latency and storage as the user's history
--     accumulates.
--   • The audit log was already covered by xp_ledger — each day's
--     completion gets its own row keyed by (user_id, source_id,
--     log_date). We don't need a per-occurrence task row for history.
--   • Mental model matches what users already know from iOS / system
--     calendars: a recurring entry is one thing, not a copy each day.
--
-- Behaviour after this migration:
--   • complete_task, after awarding XP and unlocking achievements,
--     checks whether the just-completed task was recurring.
--     - If yes: UPDATE the same row — is_done back to false,
--       completed_at cleared, due_at advanced by +1 day / +7 days.
--     - If no: leaves is_done=true so the row stays in "completed"
--       state (existing behaviour).
--   • uncomplete_task, when called on a recurring task, reverses the
--     forward shift so the user can undo a same-day mistake.
--   • xp_ledger UNIQUE(user_id, source_type, source_id, log_date)
--     prevents double-XP on the same calendar day even though
--     is_done is back to false after the shift.
-- ════════════════════════════════════════════════════════════════════

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
  v_recur_advanced  BOOLEAN := false;
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
    -- Already claimed XP for this task today. For non-recurring just
    -- mark done; for recurring leave the row alone (user already
    -- shifted it past this calendar day on the first tap).
    IF NOT v_task.is_recurring THEN
      UPDATE public.tasks
         SET is_done = true, completed_at = now(), updated_at = now()
       WHERE id = p_task_id;
    END IF;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

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

  -- ── Recurrence: shift due_at instead of inserting a new row ────
  IF v_task.is_recurring AND v_task.recurrence IS NOT NULL THEN
    v_next_due_at := CASE v_task.recurrence
      WHEN 'daily'  THEN COALESCE(v_task.due_at, now()) + INTERVAL '1 day'
      WHEN 'weekly' THEN COALESCE(v_task.due_at, now()) + INTERVAL '7 days'
      ELSE NULL
    END;

    IF v_next_due_at IS NOT NULL THEN
      -- Same row, just push it forward. is_done back to false so it
      -- shows up in tomorrow's Today list automatically. The xp_ledger
      -- entry we just wrote remains as the audit log for today's
      -- completion — no per-occurrence task row needed.
      UPDATE public.tasks
         SET is_done      = false,
             completed_at = NULL,
             due_at       = v_next_due_at,
             due_date     = v_next_due_at::date,
             updated_at   = now()
       WHERE id = p_task_id;
      v_recur_advanced := true;
    ELSE
      -- Recurrence type we don't recognize — fall through to "done".
      UPDATE public.tasks
         SET is_done = true, completed_at = now(), updated_at = now()
       WHERE id = p_task_id;
    END IF;
  ELSE
    UPDATE public.tasks
       SET is_done = true, completed_at = now(), updated_at = now()
     WHERE id = p_task_id;
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
    'recurring_advanced',     v_recur_advanced
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_task(UUID) TO authenticated;


-- uncomplete_task: also reverse the recurrence shift so undo works
-- consistently for recurring tasks.
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
  v_prev_due_at TIMESTAMPTZ;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_task FROM public.tasks
   WHERE id = p_task_id AND user_id = v_user FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'task_not_found'; END IF;

  -- We can be in one of two completion shapes:
  --   • Non-recurring: is_done=true, ledger row for today exists.
  --   • Recurring: is_done=false (already advanced), ledger row for
  --     today still exists and is our signal that the user did
  --     complete today.
  SELECT * INTO v_ledger FROM public.xp_ledger
   WHERE user_id = v_user
     AND source_type = 'task'
     AND source_id = p_task_id
     AND log_date = CURRENT_DATE
   LIMIT 1;

  IF v_ledger.id IS NULL AND NOT v_task.is_done THEN
    RETURN jsonb_build_object('ok', true, 'undone', false);
  END IF;

  -- Reverse the recurrence shift if applicable: bring due_at back to
  -- today's slot so the task is visible in Today list again.
  IF v_task.is_recurring AND v_task.recurrence IS NOT NULL THEN
    v_prev_due_at := CASE v_task.recurrence
      WHEN 'daily'  THEN v_task.due_at - INTERVAL '1 day'
      WHEN 'weekly' THEN v_task.due_at - INTERVAL '7 days'
      ELSE v_task.due_at
    END;
    UPDATE public.tasks
       SET is_done = false,
           completed_at = NULL,
           due_at = v_prev_due_at,
           due_date = v_prev_due_at::date,
           updated_at = now()
     WHERE id = p_task_id;
  ELSE
    UPDATE public.tasks
       SET is_done = false, completed_at = NULL, updated_at = now()
     WHERE id = p_task_id;
  END IF;

  -- Drop the task_logs completion entry so re-completion doesn't see
  -- a stale audit row.
  DELETE FROM public.task_logs
   WHERE user_id = v_user
     AND task_id = p_task_id
     AND action = 'completed';

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
       SET xp_total   = GREATEST(0, xp_total   - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           xp_current = GREATEST(0, xp_current - (v_ledger.xp_amount + v_ledger.discipline_xp_amount)),
           updated_at = now()
     WHERE user_id = v_user;
  END IF;

  RETURN jsonb_build_object('ok', true, 'undone', true, 'task_id', p_task_id);
END $$;

REVOKE ALL   ON FUNCTION public.uncomplete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.uncomplete_task(UUID) TO authenticated;
