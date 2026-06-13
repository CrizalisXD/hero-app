-- ════════════════════════════════════════════════════════════════════
-- Hero — 0020_energy_mechanic.sql
--
-- Wires up the "anti-burnout limit" energy mechanic the user asked for
-- after the Phase 18 visual review.
--
-- Mental model
--   • Energy is the user's daily focus budget. Creating new commitments
--     (task / habit / goal) costs energy. Completing what you already
--     have gives a small refund (you proved follow-through; spend more).
--   • The cap and recovery scale with the user's Endurance category
--     level — so investing in cardio / runs makes the system itself
--     allow more parallel work over time.
--   • Streak adds a daily bonus on top, capped, so consistency is also
--     rewarded but doesn't replace endurance progression.
--
-- Numbers (chosen so a fresh L1 user with max=100 can carry exactly one
-- goal + one good habit + one bad habit = 95 — forces a real choice,
-- not "create everything that pops to mind in your first session"):
--
--   energy_max       = 100 + (endurance_level - 1) * 10
--   hourly_regen     = 1 + floor(endurance_level / 3)         per hour
--   daily_login_bonus = 30 + LEAST(current_streak, 20)         per day
--
--   spend_energy(amount) — atomic FOR UPDATE; returns ok=false if cap
--     would be breached. Client shows "not enough energy" dialog.
--
--   regen_energy() — called on app start / Home load. Computes time
--     elapsed since last call, adds hourly regen (capped at max),
--     applies daily login bonus the first time it's called on a new
--     calendar day, and refreshes energy_max from current endurance
--     level. Idempotent within the hour.
--
--   reward_energy(amount) — internal, called by complete_task and
--     complete_habit_checkin (good habits only, slips give 0).
--
-- ════════════════════════════════════════════════════════════════════

-- Tracks when regen was last applied. NULL on legacy rows → first call
-- treats it as "long ago" and runs a full refill.
ALTER TABLE public.character_stats
  ADD COLUMN IF NOT EXISTS energy_last_regen_at TIMESTAMPTZ;

-- One-time backfill so existing rows aren't immediately granted a
-- million points of regen on next call.
UPDATE public.character_stats
   SET energy_last_regen_at = now()
 WHERE energy_last_regen_at IS NULL;


-- ── reward_energy ────────────────────────────────────────────────────
-- Internal helper. Adds energy (capped at energy_max). No-op on
-- non-positive amounts.
CREATE OR REPLACE FUNCTION public.reward_energy(p_user_id UUID, p_amount INT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_amount <= 0 THEN RETURN; END IF;
  UPDATE public.character_stats
     SET energy = LEAST(energy_max, energy + p_amount),
         updated_at = now()
   WHERE user_id = p_user_id;
END $$;


-- ── spend_energy ─────────────────────────────────────────────────────
-- Atomic spend. Returns:
--   { ok: true,  energy: <new value>, max: <cap> }            on success
--   { ok: false, energy: <unchanged>, max: <cap>, needed: <amt> } when
--     the user doesn't have enough.
-- Uses FOR UPDATE so two rapid-fire creates can't both pass the check
-- and overshoot the floor.
CREATE OR REPLACE FUNCTION public.spend_energy(p_amount INT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_energy INT;
  v_max INT;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF p_amount IS NULL OR p_amount < 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  SELECT energy, energy_max INTO v_energy, v_max
    FROM public.character_stats
   WHERE user_id = v_user
   FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'no_character_stats'; END IF;

  IF v_energy < p_amount THEN
    RETURN jsonb_build_object(
      'ok', false,
      'energy', v_energy,
      'max', v_max,
      'needed', p_amount
    );
  END IF;

  UPDATE public.character_stats
     SET energy = energy - p_amount,
         updated_at = now()
   WHERE user_id = v_user;

  RETURN jsonb_build_object(
    'ok', true,
    'energy', v_energy - p_amount,
    'max', v_max
  );
END $$;

REVOKE ALL   ON FUNCTION public.spend_energy(INT) FROM public;
GRANT EXECUTE ON FUNCTION public.spend_energy(INT) TO authenticated;


-- ── regen_energy ─────────────────────────────────────────────────────
-- Idempotent within the hour. Bring energy up to date based on time
-- elapsed since last call and (if we crossed a calendar day) the
-- streak-scaled daily bonus. Also refreshes energy_max from the
-- current Endurance category level.
CREATE OR REPLACE FUNCTION public.regen_energy()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_energy INT;
  v_max INT;
  v_last TIMESTAMPTZ;
  v_now TIMESTAMPTZ := now();
  v_today DATE := CURRENT_DATE;
  v_endurance_level INT;
  v_new_max INT;
  v_hourly_rate INT;
  v_streak INT;
  v_daily_bonus INT := 0;
  v_hours NUMERIC;
  v_added INT;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT energy, energy_max, energy_last_regen_at
    INTO v_energy, v_max, v_last
    FROM public.character_stats
   WHERE user_id = v_user
   FOR UPDATE;

  IF NOT FOUND THEN RAISE EXCEPTION 'no_character_stats'; END IF;

  -- Refresh cap from current Endurance level.
  SELECT COALESCE(level, 1) INTO v_endurance_level
    FROM public.category_progress
   WHERE user_id = v_user AND category = 'endurance';
  v_new_max := 100 + (COALESCE(v_endurance_level, 1) - 1) * 10;

  -- Hourly regen rate scales with Endurance level (1, 1, 2, 2, 2, 3, …).
  v_hourly_rate := 1 + (COALESCE(v_endurance_level, 1) / 3);

  -- Daily login bonus, scaled with current habit streak.
  SELECT COALESCE(current_streak, 0) INTO v_streak
    FROM public.meta_stats WHERE user_id = v_user;

  -- Treat NULL last_regen_at (legacy rows) as "long ago" → full refill.
  IF v_last IS NULL THEN
    v_added := v_new_max;
  ELSE
    -- Daily bonus: if we crossed at least one calendar day since the
    -- last regen, apply one streak-scaled bonus (we don't multiply by
    -- days_passed — that would let dormant users come back to free
    -- cap; the daily bonus is a "show up and play" reward).
    IF v_last::date < v_today THEN
      v_daily_bonus := 30 + LEAST(v_streak, 20);
    END IF;

    v_hours := EXTRACT(EPOCH FROM (v_now - v_last)) / 3600.0;
    v_added := v_daily_bonus + FLOOR(v_hours * v_hourly_rate)::INT;
  END IF;

  IF v_added < 0 THEN v_added := 0; END IF;

  UPDATE public.character_stats
     SET energy_max = v_new_max,
         energy     = LEAST(v_new_max, energy + v_added),
         energy_last_regen_at = v_now,
         updated_at = now()
   WHERE user_id = v_user
   RETURNING energy INTO v_energy;

  RETURN jsonb_build_object(
    'ok', true,
    'energy', v_energy,
    'max', v_new_max,
    'added', v_added,
    'hourly_rate', v_hourly_rate,
    'daily_bonus', v_daily_bonus
  );
END $$;

REVOKE ALL   ON FUNCTION public.regen_energy() FROM public;
GRANT EXECUTE ON FUNCTION public.regen_energy() TO authenticated;


-- ── Wire energy rewards into existing complete_* RPCs ────────────────
-- complete_task and complete_habit_checkin already do the heavy lifting
-- for XP and achievements; we just sneak a reward_energy(5) / (3) in.
-- Good habits give +3 on check-in, bad habits give 0 (slipping shouldn't
-- restore the budget — that's the whole point).

-- complete_task: append +5 energy reward at the very end of the non-
-- duplicate branch. Simpler than rewriting the whole function — we use
-- AFTER complete_task via a thin wrapper trigger, but Postgres doesn't
-- trigger on function calls. So we re-define the function with the
-- one extra line. Copy-paste of 0016, just adding the reward call.
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

  -- Energy reward for following through.
  PERFORM public.reward_energy(v_user_id, 5);

  PERFORM public.check_and_unlock_achievements(
    v_user_id,
    'task_completed',
    jsonb_build_object('task_id', p_task_id, 'category', v_task.main_category)
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


-- complete_habit_checkin — same wiring, +3 for good habits, 0 for bad.
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
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT COALESCE(array_agg(achievement_id), '{}'::TEXT[])
    INTO v_pre_ids
    FROM public.user_achievements
   WHERE user_id = v_user_id;

  SELECT * INTO v_habit FROM public.habits
   WHERE id = p_habit_id AND user_id = v_user_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  INSERT INTO public.habit_logs (habit_id, user_id, log_date, value, xp_earned)
  VALUES (
    p_habit_id, v_user_id, v_today, p_value,
    CASE WHEN v_habit.type = 'bad' THEN 0
         ELSE v_habit.xp_reward + v_habit.discipline_xp_reward END
  )
  ON CONFLICT (habit_id, log_date) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;

  -- ── BAD HABIT BRANCH (slip) ───────────────────────────────────────
  IF v_habit.type = 'bad' THEN
    UPDATE public.habits
       SET current_streak = 0,
           last_slip_date = v_today,
           updated_at     = now()
     WHERE id = p_habit_id;

    UPDATE public.meta_stats
       SET discipline_xp = GREATEST(0, discipline_xp - 2),
           last_active_date = v_today,
           updated_at = now()
     WHERE user_id = v_user_id;

    -- No energy reward for slipping. (The whole point.)

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

  -- ── GOOD HABIT BRANCH ─────────────────────────────────────────────
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

  -- Energy reward for good-habit follow-through.
  PERFORM public.reward_energy(v_user_id, 3);

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
