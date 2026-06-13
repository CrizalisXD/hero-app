-- ════════════════════════════════════════════════════════════════════
-- Hero — 0019_bad_habits.sql
--
-- Wires up the bad-habit ("anti-habit") flow that Phase 6 deferred.
--
-- Mental model: a bad habit is something the user wants to STOP doing.
-- The streak shown to the user is "дней без срыва" — days since the
-- last slip. Tapping check-in for a bad habit means "I slipped today",
-- which:
--   • resets habits.current_streak to 0
--   • stamps habits.last_slip_date = today
--   • deducts a small discipline penalty (-2)
--   • awards 0 XP (slipping is not a reward event)
--
-- Why a stored last_slip_date column instead of computing from logs:
-- the client renders a list of habits in one query; joining logs per
-- row would be N+1. With last_slip_date on the row, display_streak can
-- be computed in Dart as max(0, today - last_slip_date) — or, for
-- never-slipped habits, today - created_at::date.
--
-- Good habits keep their old contract unchanged.
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.habits
  ADD COLUMN IF NOT EXISTS last_slip_date DATE;


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
  v_pre_ids        TEXT[];
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- For diff-snapshot of newly-unlocked achievements (Phase 18 hotfix 0013).
  SELECT COALESCE(array_agg(achievement_id), '{}'::TEXT[])
    INTO v_pre_ids
    FROM public.user_achievements
   WHERE user_id = v_user_id;

  SELECT * INTO v_habit FROM public.habits
   WHERE id = p_habit_id AND user_id = v_user_id
   FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  -- Idempotent same-day log insert.
  INSERT INTO public.habit_logs
    (habit_id, user_id, log_date, value, xp_earned)
  VALUES
    (p_habit_id, v_user_id, v_today, p_value,
     CASE WHEN v_habit.type = 'bad' THEN 0
          ELSE v_habit.xp_reward + v_habit.discipline_xp_reward END)
  ON CONFLICT (habit_id, log_date) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;

  -- ═══════════════════════════════════════════════════════════════
  -- BAD HABIT BRANCH (slip)
  -- ═══════════════════════════════════════════════════════════════
  IF v_habit.type = 'bad' THEN
    UPDATE public.habits
       SET current_streak = 0,
           last_slip_date = v_today,
           updated_at     = now()
     WHERE id = p_habit_id;

    -- Small discipline penalty. Floor at 0 so it never goes negative
    -- (Phase 18 design choice — meta_stats shouldn't surprise the user
    -- with negative aggregates).
    UPDATE public.meta_stats
       SET discipline_xp = GREATEST(0, discipline_xp - 2),
           last_active_date = v_today,
           updated_at = now()
     WHERE user_id = v_user_id;

    -- Achievements: still check, in case a "first slip honesty" or
    -- similar exists in the catalog.
    PERFORM public.check_and_unlock_achievements(
      v_user_id,
      'habit_slipped',
      jsonb_build_object('habit_id', p_habit_id)
    );

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
      'habit_id',               p_habit_id,
      'slip',                   true,
      'category',               v_habit.main_category,
      'category_xp',            0,
      'discipline_xp',         -2,
      'current_streak',         0,
      'last_slip_date',         v_today,
      'unlocked_achievements',  v_unlocked
    );
  END IF;

  -- ═══════════════════════════════════════════════════════════════
  -- GOOD HABIT BRANCH (existing behaviour, unchanged)
  -- ═══════════════════════════════════════════════════════════════
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
  ON CONFLICT DO NOTHING;

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

  PERFORM public.check_and_unlock_achievements(
    v_user_id,
    'habit_completed',
    jsonb_build_object('habit_id', p_habit_id, 'streak', v_new_streak)
  );

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
    'habit_id',               p_habit_id,
    'slip',                   false,
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
