-- ═══════════════════════════════════════════════════════════════════
-- XP_SYSTEM_TZ.md §10.1–3 + §10.6: серверная авторитетность XP.
--
--  [D5] complete_task / complete_habit_checkin считают XP сами:
--       category_xp = base_xp(БД) × difficulty × duration × importance.
--       Клиентский xp_reward ИГНОРИРУЕТСЯ (перезаписывается для UI).
--  [D4] base_xp — только таблица categories (из categories.json убран).
--  [D6] Единый экспоненциальный левелинг 200×1.5^(n−1) и для
--       category_progress (+ xp_current / xp_to_next), и для героя;
--       reward_xp ачивок — через apply_xp_gain (не мимо кривой).
--  [D7] description_ru/en категорий — принцип «что измеряет».
--  [D2] secondary_categories — display-only, XP не даёт (комментарии).
--  [§6] Discipline XP — серверный канон: daily task = 3, habit = 4.
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. Множители и серверная формула XP ─────────────────────────────

CREATE OR REPLACE FUNCTION public.xp_mult_difficulty(p task_difficulty)
RETURNS NUMERIC LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p
    WHEN 'easy'   THEN 0.75
    WHEN 'normal' THEN 1.0
    WHEN 'hard'   THEN 1.35
    WHEN 'epic'   THEN 2.0
  END;
$$;

CREATE OR REPLACE FUNCTION public.xp_mult_duration(p task_duration)
RETURNS NUMERIC LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p
    WHEN 'short'  THEN 0.8
    WHEN 'medium' THEN 1.0
    WHEN 'long'   THEN 1.25
  END;
$$;

CREATE OR REPLACE FUNCTION public.xp_mult_importance(p task_importance)
RETURNS NUMERIC LANGUAGE sql IMMUTABLE AS $$
  SELECT CASE p
    WHEN 'low'    THEN 0.8
    WHEN 'normal' THEN 1.0
    WHEN 'high'   THEN 1.25
  END;
$$;

-- [D5] Единственная точка расчёта величины награды.
-- base_xp берётся из БД (D4). Floor 1: выполненное дело не может стоить 0.
CREATE OR REPLACE FUNCTION public.calc_category_xp(
  p_category   task_category,
  p_difficulty task_difficulty,
  p_duration   task_duration,
  p_importance task_importance
)
RETURNS INT LANGUAGE sql STABLE AS $$
  SELECT GREATEST(1, ROUND(
    c.base_xp
    * public.xp_mult_difficulty(p_difficulty)
    * public.xp_mult_duration(p_duration)
    * public.xp_mult_importance(p_importance)
  ))::INT
  FROM public.categories c
  WHERE c.id = p_category;
$$;

GRANT EXECUTE ON FUNCTION public.calc_category_xp(task_category, task_difficulty, task_duration, task_importance) TO authenticated;

-- ── 2. [D6] category_progress → экспонента + прогресс внутри уровня ─

ALTER TABLE public.category_progress
  ADD COLUMN IF NOT EXISTS xp_current INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS xp_to_next INT NOT NULL DEFAULT 200;

-- Аналог apply_xp_gain для атрибута: тот же закон calc_xp_to_next
-- (200×1.5^(n−1)), тот же перелив остатка при мультиапе.
CREATE OR REPLACE FUNCTION public.apply_category_xp_gain(
  p_user_id  UUID,
  p_category task_category,
  p_xp       INT
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_level INT; v_current INT; v_to_next INT; v_total INT;
  v_level_before INT;
BEGIN
  SELECT level, xp_current, xp_to_next, xp_total
    INTO v_level, v_current, v_to_next, v_total
    FROM public.category_progress
   WHERE user_id = p_user_id AND category = p_category
   FOR UPDATE;
  IF NOT FOUND THEN
    -- Строка создаётся бутстрапом; страховка на случай пропуска.
    INSERT INTO public.category_progress (user_id, category)
    VALUES (p_user_id, p_category)
    ON CONFLICT DO NOTHING;
    v_level := 1; v_current := 0; v_total := 0;
    v_to_next := public.calc_xp_to_next(1);
  END IF;

  v_level_before := v_level;
  v_total   := v_total + p_xp;
  v_current := v_current + p_xp;
  WHILE v_current >= v_to_next LOOP
    v_current := v_current - v_to_next;
    v_level   := v_level + 1;
    v_to_next := public.calc_xp_to_next(v_level);
  END LOOP;

  UPDATE public.category_progress
     SET xp_total = v_total, level = v_level,
         xp_current = v_current, xp_to_next = v_to_next,
         updated_at = now()
   WHERE user_id = p_user_id AND category = p_category;

  RETURN jsonb_build_object(
    'category', p_category,
    'level_before', v_level_before, 'level_after', v_level,
    'xp_current', v_current, 'xp_to_next', v_to_next, 'xp_total', v_total
  );
END $$;

REVOKE ALL ON FUNCTION public.apply_category_xp_gain(UUID, task_category, INT) FROM public;

-- Бэкфилл: пересчитать уровни всех существующих строк по экспоненте.
-- Уровни могут ОПУСТИТЬСЯ относительно старого линейного закона
-- (xp/200): экспонента дороже начиная со 2-го уровня — это ожидаемое
-- следствие D6, xp_total не теряется.
DO $$
DECLARE
  r RECORD; v_level INT; v_current INT; v_to_next INT;
BEGIN
  FOR r IN SELECT user_id, category, xp_total FROM public.category_progress LOOP
    v_level := 1;
    v_current := r.xp_total;
    v_to_next := public.calc_xp_to_next(1);
    WHILE v_current >= v_to_next LOOP
      v_current := v_current - v_to_next;
      v_level   := v_level + 1;
      v_to_next := public.calc_xp_to_next(v_level);
    END LOOP;
    UPDATE public.category_progress
       SET level = v_level, xp_current = v_current,
           xp_to_next = v_to_next, updated_at = now()
     WHERE user_id = r.user_id AND category = r.category;
  END LOOP;
END $$;

-- ── 3. [D5] complete_task: сервер считает сам ────────────────────────
-- Тело = актуальная версия (20260524000026, recurring in-place); диф:
--   • v_xp из calc_category_xp (клиентский xp_reward игнорируется);
--   • v_discipline — серверный канон §6 (recurring daily → 3, иначе 0);
--   • category_progress через apply_category_xp_gain (экспонента, D6);
--   • tasks.xp_reward перезаписывается серверным значением (для UI).

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
  v_cat_result      JSONB;
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

  -- [D5] Величину награды определяет ТОЛЬКО сервер.
  v_xp         := public.calc_category_xp(
                    v_task.main_category, v_task.difficulty,
                    v_task.duration, v_task.importance);
  -- [§6] Серверный канон дисциплины: ежедневная (recurring) задача = 3.
  v_discipline := CASE WHEN v_task.is_recurring THEN 3 ELSE 0 END;
  v_xp_total   := v_xp + v_discipline;

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'task', p_task_id, v_task.main_category, v_xp, v_discipline, CURRENT_DATE)
  ON CONFLICT DO NOTHING;

  GET DIAGNOSTICS v_ledger_inserted = ROW_COUNT;
  IF v_ledger_inserted = 0 THEN
    IF NOT v_task.is_recurring THEN
      UPDATE public.tasks
         SET is_done = true, completed_at = now(), updated_at = now()
       WHERE id = p_task_id;
    END IF;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;

  INSERT INTO public.task_logs (user_id, task_id, action, xp_earned)
  VALUES (v_user_id, p_task_id, 'completed', v_xp_total);

  -- [D6] Атрибут растёт по той же экспоненте, что и герой.
  -- [D2] secondary_categories НЕ читаем: XP всегда только в main_category.
  v_cat_result := public.apply_category_xp_gain(
                    v_user_id, v_task.main_category, v_xp);

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
      UPDATE public.tasks
         SET is_done      = false,
             completed_at = NULL,
             due_at       = v_next_due_at,
             due_date     = v_next_due_at::date,
             xp_reward    = v_xp,
             updated_at   = now()
       WHERE id = p_task_id;
      v_recur_advanced := true;
    ELSE
      UPDATE public.tasks
         SET is_done = true, completed_at = now(),
             xp_reward = v_xp, updated_at = now()
       WHERE id = p_task_id;
    END IF;
  ELSE
    UPDATE public.tasks
       SET is_done = true, completed_at = now(),
           xp_reward = v_xp, updated_at = now()
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
    'category_progress',      v_cat_result,
    'unlocked_achievements',  v_unlocked,
    'recurring_advanced',     v_recur_advanced
  );
END $$;

-- ── 4. [D5] complete_habit_checkin: сервер считает сам ──────────────
-- Тело = актуальная версия (20260524000017, energy + bad habits); диф
-- тот же: серверный XP, дисциплина = 4 (§6), экспонента атрибута.

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
  v_cat_result     JSONB;
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

  -- [D5] Величина награды — только сервер. Считаем ДО записи лога,
  -- чтобы habit_logs.xp_earned хранил серверное значение.
  IF v_habit.type = 'bad' THEN
    v_xp := 0; v_discipline := 0;
  ELSE
    v_xp         := public.calc_category_xp(
                      v_habit.main_category, v_habit.difficulty,
                      v_habit.duration, v_habit.importance);
    v_discipline := 4;  -- [§6] complete_habit = 4
  END IF;
  v_xp_total := v_xp + v_discipline;

  INSERT INTO public.habit_logs (habit_id, user_id, log_date, value, xp_earned)
  VALUES (p_habit_id, v_user_id, v_today, p_value, v_xp_total)
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
         xp_reward      = v_xp,
         updated_at     = now()
   WHERE id = p_habit_id;

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user_id, 'habit', p_habit_id, v_habit.main_category, v_xp, v_discipline, v_today)
  ON CONFLICT DO NOTHING;

  -- [D6] Экспонента атрибута; [D2] secondary_categories не читаем.
  v_cat_result := public.apply_category_xp_gain(
                    v_user_id, v_habit.main_category, v_xp);

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
    'category_progress',      v_cat_result,
    'unlocked_achievements',  v_unlocked
  );
END $$;

-- ── 5. [D6-следствие] Ачивки: reward_xp через apply_xp_gain ─────────
-- Тело = актуальная версия (20260524000006, challenges); диф — только
-- блок начисления reward_xp.

CREATE OR REPLACE FUNCTION public.check_and_unlock_achievements(
  p_user_id    UUID,
  p_event_type TEXT  DEFAULT 'manual',
  p_payload    JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_achievement RECORD;
  v_meta        meta_stats%ROWTYPE;
  v_char        character_stats%ROWTYPE;
  v_unlocked    JSONB := '[]'::jsonb;
  v_meets       BOOLEAN;
  v_current     NUMERIC;
BEGIN
  IF p_user_id IS NULL THEN RETURN v_unlocked; END IF;

  SELECT * INTO v_meta FROM public.meta_stats      WHERE user_id = p_user_id;
  SELECT * INTO v_char FROM public.character_stats WHERE user_id = p_user_id;

  FOR v_achievement IN
    SELECT a.* FROM public.achievements a
     WHERE NOT EXISTS (
       SELECT 1 FROM public.user_achievements ua
        WHERE ua.user_id = p_user_id AND ua.achievement_id = a.id
     )
     ORDER BY a.sort_order
  LOOP
    v_meets   := false;
    v_current := 0;

    CASE v_achievement.condition_type
      WHEN 'streak_days' THEN
        v_current := COALESCE(v_meta.current_streak, 0);
        v_meets   := v_current >= v_achievement.condition_value;

      WHEN 'total_level' THEN
        v_current := COALESCE(v_char.level, 1);
        v_meets   := v_current >= v_achievement.condition_value;

      WHEN 'goals_created' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.goals WHERE user_id = p_user_id AND is_deleted = false;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'goals_completed' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.goals WHERE user_id = p_user_id AND status = 'completed';
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'habit_streak' THEN
        SELECT COALESCE(MAX(current_streak), 0)::NUMERIC INTO v_current
          FROM public.habits WHERE user_id = p_user_id;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'tasks_completed' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.task_logs
         WHERE user_id = p_user_id AND action = 'completed';
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'friend_count' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.friendships
         WHERE user_a_id = p_user_id OR user_b_id = p_user_id;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'challenge_joined' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.challenge_participants
         WHERE user_id = p_user_id;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'challenge_completed' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.challenge_participants
         WHERE user_id = p_user_id AND status = 'completed';
        v_meets := v_current >= v_achievement.condition_value;

      ELSE v_meets := false;
    END CASE;

    IF v_meets THEN
      BEGIN
        INSERT INTO public.user_achievements
          (user_id, achievement_id, progress_value)
        VALUES (p_user_id, v_achievement.id, v_current);

        IF v_achievement.reward_xp > 0 THEN
          -- [D6-следствие] Через кривую, а не напрямую в xp_total —
          -- иначе награда «исчезает» из прогресса уровня.
          PERFORM public.apply_xp_gain(p_user_id, v_achievement.reward_xp);
        END IF;

        IF v_achievement.reward_coins > 0 THEN
          UPDATE public.meta_stats
             SET coins      = coins + v_achievement.reward_coins,
                 updated_at = now()
           WHERE user_id = p_user_id;
        END IF;

        v_unlocked := v_unlocked || jsonb_build_object(
          'id',              v_achievement.id,
          'title_key',       v_achievement.title_key,
          'description_key', v_achievement.description_key,
          'rarity',          v_achievement.rarity,
          'icon_key',        v_achievement.icon_key,
          'reward_xp',       v_achievement.reward_xp,
          'reward_coins',    v_achievement.reward_coins
        );
      EXCEPTION WHEN unique_violation THEN
        NULL;
      END;
    END IF;
  END LOOP;

  RETURN v_unlocked;
END $$;

-- ── 6. [D7] Описания атрибутов — принцип, не список примеров ────────

UPDATE public.categories SET
  description_ru = 'Приложил силу, нарастил мышцу — анаэробная нагрузка. Длительное кардио — Выносливость, растяжка — Здоровье.',
  description_en = 'Applied force, built muscle — anaerobic load. Long cardio is Endurance; stretching is Health.'
WHERE id = 'strength';

UPDATE public.categories SET
  description_ru = 'Держал аэробную нагрузку по времени или дистанции. Силовые подходы — Сила, сон и отдых — Здоровье.',
  description_en = 'Sustained aerobic load over time or distance. Strength sets are Strength; sleep and rest are Health.'
WHERE id = 'endurance';

UPDATE public.categories SET
  description_ru = 'Освоил знание или навык — когнитивный вход. Медитация — Здоровье, создание текста или рисунка — Творчество.',
  description_en = 'Acquired knowledge or a skill — cognitive input. Meditation is Health; creating text or art is Creativity.'
WHERE id = 'mind';

UPDATE public.categories SET
  description_ru = 'Поддержал или восстановил тело и психику — не тренировка. Сон, питание, врачи, растяжка, медитация. Активная тренировка — Сила или Выносливость.',
  description_en = 'Maintained or restored body and mind — not a workout. Sleep, nutrition, doctors, stretching, meditation. Active training is Strength or Endurance.'
WHERE id = 'health';

UPDATE public.categories SET
  description_ru = 'Вложился в отношения и связи: общение, семья, друзья, нетворкинг.',
  description_en = 'Invested in relationships and connections: communication, family, friends, networking.'
WHERE id = 'social';

UPDATE public.categories SET
  description_ru = 'Управлял деньгами: бюджет, накопления, инвестиции, оплаты, заработок.',
  description_en = 'Managed money: budget, savings, investments, payments, income.'
WHERE id = 'finance';

UPDATE public.categories SET
  description_ru = 'Создал что-то — творческий выход: музыка, рисование, письмо, дизайн. Обучение навыку — Разум.',
  description_en = 'Created something — creative output: music, drawing, writing, design. Learning a skill is Mind.'
WHERE id = 'creativity';

-- ── 7. [D2] + [D5] Комментарии-предохранители в схеме ───────────────

COMMENT ON COLUMN public.tasks.secondary_categories IS
  '[D2, XP_SYSTEM_TZ §1] Display-only метка родства. XP всегда идёт только в main_category — complete_task намеренно НЕ читает это поле, это не баг.';
COMMENT ON COLUMN public.habits.secondary_categories IS
  '[D2, XP_SYSTEM_TZ §1] Display-only метка родства. XP всегда идёт только в main_category — complete_habit_checkin намеренно НЕ читает это поле, это не баг.';
COMMENT ON COLUMN public.tasks.xp_reward IS
  '[D5, XP_SYSTEM_TZ §3] НЕ источник награды: сервер считает XP сам из base_xp(БД) × множители. Значение перезаписывается серверным при завершении (для отображения).';
COMMENT ON COLUMN public.habits.xp_reward IS
  '[D5, XP_SYSTEM_TZ §3] НЕ источник награды: сервер считает XP сам. Перезаписывается серверным значением при чек-ине.';

-- ── 8. [D3] Коины за стрик — в ачивки (streak_rewards из JSON удалён) ─
-- Старая шкала (7д→50 коинов) сохранена как опорная точка.

UPDATE public.achievements SET reward_coins = 15  WHERE id = 'streak_3'  AND reward_coins = 0;
UPDATE public.achievements SET reward_coins = 30  WHERE id = 'streak_5'  AND reward_coins = 0;
UPDATE public.achievements SET reward_coins = 50  WHERE id = 'streak_7'  AND reward_coins = 0;
UPDATE public.achievements SET reward_coins = 180 WHERE id = 'streak_21' AND reward_coins = 0;
