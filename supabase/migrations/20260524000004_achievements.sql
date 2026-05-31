-- ════════════════════════════════════════════════════════════════════
-- Hero — 0006_achievements.sql  (Phase 12)
--
-- Adds:
--   - achievements    (catalog of 15 seeded achievements)
--   - user_achievements (per-user unlocks, UNIQUE protects from dupes)
--   - RPC check_and_unlock_achievements(user_id, event_type, payload)
--   - Updated complete_task + complete_habit_checkin → call the checker
--     and return unlocked_achievements: [...] for the popup flow.
-- ════════════════════════════════════════════════════════════════════

-- 1) ── Tables ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.achievements (
  id               TEXT PRIMARY KEY,
  title_key        TEXT NOT NULL,
  description_key  TEXT NOT NULL,
  category         TEXT NOT NULL CHECK (category IN (
    'streak','level','task','habit','goal','social','challenge','category','seasonal'
  )),
  rarity           TEXT NOT NULL CHECK (rarity IN (
    'common','rare','epic','legendary'
  )) DEFAULT 'common',
  icon_key         TEXT NOT NULL,
  condition_type   TEXT NOT NULL,
  condition_value  NUMERIC NOT NULL,
  reward_xp        INT NOT NULL DEFAULT 0,
  reward_coins     INT NOT NULL DEFAULT 0,
  reward_title_key TEXT,
  is_hidden        BOOLEAN NOT NULL DEFAULT FALSE,
  sort_order       INT NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  achievement_id  TEXT NOT NULL REFERENCES public.achievements(id) ON DELETE CASCADE,
  unlocked_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  progress_value  NUMERIC NOT NULL DEFAULT 0,
  is_claimed      BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user
  ON public.user_achievements (user_id);

-- ── RLS ────────────────────────────────────────────────────────────
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_user_achievements_own ON public.user_achievements;
CREATE POLICY p_user_achievements_own ON public.user_achievements
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- achievements is a public catalog; authenticated users can SELECT.
GRANT SELECT ON public.achievements TO authenticated;

-- 2) ── Seed 15 achievements (TZ §40.4) ──────────────────────────────
INSERT INTO public.achievements
  (id, title_key, description_key, category, rarity, icon_key,
   condition_type, condition_value, reward_xp, sort_order)
VALUES
  ('streak_3',  'achievementStreak3Title',  'achievementStreak3Body',  'streak','common','flame',    'streak_days',  3,   25,  10),
  ('streak_5',  'achievementStreak5Title',  'achievementStreak5Body',  'streak','common','flame',    'streak_days',  5,   50,  20),
  ('streak_7',  'achievementStreak7Title',  'achievementStreak7Body',  'streak','rare',  'flame',    'streak_days',  7,  100,  30),
  ('streak_21', 'achievementStreak21Title', 'achievementStreak21Body', 'streak','epic',  'flame',    'streak_days', 21,  250,  40),

  ('level_5',   'achievementLevel5Title',   'achievementLevel5Body',   'level', 'common','star',     'total_level',  5,   50, 100),
  ('level_10',  'achievementLevel10Title',  'achievementLevel10Body',  'level', 'rare',  'star',     'total_level', 10,  150, 110),
  ('level_30',  'achievementLevel30Title',  'achievementLevel30Body',  'level', 'epic',  'star',     'total_level', 30,  500, 120),

  ('first_goal',      'achievementFirstGoalTitle',     'achievementFirstGoalBody',     'goal','common','flag',  'goals_created',   1,  25, 200),
  ('first_goal_done', 'achievementFirstGoalDoneTitle', 'achievementFirstGoalDoneBody', 'goal','rare',  'flag',  'goals_completed', 1, 100, 210),

  ('habit_7',  'achievementHabit7Title',  'achievementHabit7Body',  'habit','common','calendar', 'habit_streak',  7,  50, 300),
  ('habit_21', 'achievementHabit21Title', 'achievementHabit21Body', 'habit','epic',  'calendar', 'habit_streak', 21, 250, 310),

  ('task_100', 'achievementTask100Title', 'achievementTask100Body', 'task','rare','check', 'tasks_completed', 100, 150, 400),

  ('social_first_friend', 'achievementSocialFirstFriendTitle', 'achievementSocialFirstFriendBody', 'social','common','users',  'friend_count',         1,  25, 500),
  ('challenge_first',     'achievementChallengeFirstTitle',    'achievementChallengeFirstBody',    'challenge','common','swords', 'challenge_joined',    1,  25, 600),
  ('challenge_complete',  'achievementChallengeCompleteTitle', 'achievementChallengeCompleteBody', 'challenge','rare',  'swords', 'challenge_completed', 1, 100, 610)
ON CONFLICT (id) DO NOTHING;

-- 3) ── RPC: check_and_unlock_achievements ──────────────────────────
-- Iterates all unowned achievements, tests condition, inserts on match.
-- Reward XP is applied DIRECTLY to character_stats (no apply_xp_gain
-- recursion — see TZ §"Подводные камни" #1). Coins go through meta_stats.
-- Returns a JSONB array of newly-unlocked achievements for the popup.
CREATE OR REPLACE FUNCTION public.check_and_unlock_achievements(
  p_user_id    UUID,
  p_event_type TEXT  DEFAULT 'manual',
  p_payload    JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_achievement RECORD;
  v_meta        meta_stats%ROWTYPE;
  v_char        character_stats%ROWTYPE;
  v_unlocked    JSONB := '[]'::jsonb;
  v_meets       BOOLEAN;
  v_current     NUMERIC;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN v_unlocked;
  END IF;

  SELECT * INTO v_meta FROM public.meta_stats       WHERE user_id = p_user_id;
  SELECT * INTO v_char FROM public.character_stats  WHERE user_id = p_user_id;

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
          FROM public.goals
         WHERE user_id = p_user_id AND is_deleted = false;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'goals_completed' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.goals
         WHERE user_id = p_user_id AND status = 'completed';
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'habit_streak' THEN
        SELECT COALESCE(MAX(current_streak), 0)::NUMERIC INTO v_current
          FROM public.habits
         WHERE user_id = p_user_id;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'tasks_completed' THEN
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.task_logs
         WHERE user_id = p_user_id AND action = 'completed';
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'friend_count' THEN
        -- Phase 13 will provide friendships; locked for now.
        v_meets := false;

      WHEN 'challenge_joined', 'challenge_completed' THEN
        -- Phase 14 will provide challenge_participants; locked for now.
        v_meets := false;

      ELSE
        v_meets := false;
    END CASE;

    IF v_meets THEN
      BEGIN
        INSERT INTO public.user_achievements
          (user_id, achievement_id, progress_value)
        VALUES
          (p_user_id, v_achievement.id, v_current);

        IF v_achievement.reward_xp > 0 THEN
          UPDATE public.character_stats
             SET xp_total   = xp_total   + v_achievement.reward_xp,
                 xp_current = xp_current + v_achievement.reward_xp,
                 updated_at = now()
           WHERE user_id = p_user_id;
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
        -- Race: another concurrent call inserted first. Silently skip.
        NULL;
      END;
    END IF;
  END LOOP;

  RETURN v_unlocked;
END $$;

REVOKE ALL ON FUNCTION public.check_and_unlock_achievements(UUID, TEXT, JSONB) FROM public;
GRANT EXECUTE ON FUNCTION public.check_and_unlock_achievements(UUID, TEXT, JSONB) TO authenticated;

-- 4) ── Updated complete_task ──────────────────────────────────────
-- Same logic as 0001 + hotfix, plus checker invocation at the end.
-- Adds unlocked_achievements: [...] to the response payload.
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
  ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay DO NOTHING;

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

-- 5) ── Updated complete_habit_checkin ──────────────────────────────
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
  ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay DO NOTHING;

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
