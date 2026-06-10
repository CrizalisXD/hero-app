-- ════════════════════════════════════════════════════════════════════
-- Hero — 0008_challenges_lite.sql  (Phase 14)
--
-- Adds:
--   - 3 tables: challenges, challenge_participants, challenge_events
--   - 2 seed system challenges (open-ended through 2099)
--   - 5 RPCs: list_system_challenges, list_my_challenges,
--             join_challenge, leave_challenge, process_challenge_progress
--   - 2 triggers on task_logs / habit_logs → progress increment
--   - Updated check_and_unlock_achievements: challenge_joined /
--     challenge_completed condition_types now read real counts.
-- ════════════════════════════════════════════════════════════════════

-- 1) ── challenges (catalog) ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.challenges (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id      UUID REFERENCES public.users(id) ON DELETE SET NULL,
  challenge_type     TEXT NOT NULL CHECK (challenge_type IN ('system','user','friend')),
  metric_type        TEXT NOT NULL CHECK (metric_type IN (
                       'streak','count','distance','xp','habit','category','activity_day'
                     )),
  title_key          TEXT NOT NULL,
  description_key    TEXT,
  title_custom       TEXT,
  description_custom TEXT,
  start_at           TIMESTAMPTZ NOT NULL,
  end_at             TIMESTAMPTZ NOT NULL,
  target_value       NUMERIC NOT NULL,
  category           TEXT,
  reward_xp          INT NOT NULL DEFAULT 0,
  is_public          BOOLEAN NOT NULL DEFAULT FALSE,
  is_active          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);
CREATE INDEX IF NOT EXISTS idx_challenges_active ON public.challenges (is_active, end_at);
DROP TRIGGER IF EXISTS tg_challenges_updated_at ON public.challenges;
CREATE TRIGGER tg_challenges_updated_at
  BEFORE UPDATE ON public.challenges
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_challenges_view ON public.challenges;
CREATE POLICY p_challenges_view ON public.challenges
  FOR SELECT USING (
    challenge_type = 'system'
    OR owner_user_id = auth.uid()
    OR is_public = true
  );

-- 2) ── challenge_participants ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.challenge_participants (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id        UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  progress_value      NUMERIC NOT NULL DEFAULT 0,
  status              TEXT NOT NULL CHECK (status IN ('joined','completed','failed','left')) DEFAULT 'joined',
  joined_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at        TIMESTAMPTZ,
  last_activity_date  DATE,
  streak_current      INT NOT NULL DEFAULT 0,
  UNIQUE(challenge_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_cp_user_status
  ON public.challenge_participants (user_id, status);
ALTER TABLE public.challenge_participants ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_cp_own ON public.challenge_participants;
CREATE POLICY p_cp_own ON public.challenge_participants
  FOR ALL USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- 3) ── challenge_events (audit log) ───────────────────────────────
CREATE TABLE IF NOT EXISTS public.challenge_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenge_id  UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  event_type    TEXT NOT NULL,
  value_delta   NUMERIC NOT NULL DEFAULT 0,
  source_type   TEXT,
  source_id     UUID,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ce_cp
  ON public.challenge_events (challenge_id, user_id, created_at DESC);
ALTER TABLE public.challenge_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_ce_own ON public.challenge_events;
CREATE POLICY p_ce_own ON public.challenge_events
  FOR SELECT USING (user_id = auth.uid());

-- 4) ── Seed: 2 system challenges (open-ended through 2099) ────────
INSERT INTO public.challenges
  (id, challenge_type, metric_type, title_key, description_key,
   start_at, end_at, target_value, reward_xp, is_active)
VALUES
  ('11111111-1111-1111-1111-100000000001',
   'system', 'activity_day',
   'challengeSevenDaysActivityTitle', 'challengeSevenDaysActivityBody',
   '2026-01-01 00:00:00+00', '2099-12-31 23:59:59+00',
   7, 200, true),
  ('11111111-1111-1111-1111-100000000002',
   'system', 'distance',
   'challengeMonthlyStepsTitle', 'challengeMonthlyStepsBody',
   '2026-01-01 00:00:00+00', '2099-12-31 23:59:59+00',
   30000, 500, true)
ON CONFLICT (id) DO NOTHING;
-- distance in metres: 30 km = 30 000 m

-- 5) ── RPC: list_system_challenges ─────────────────────────────────
CREATE OR REPLACE FUNCTION public.list_system_challenges()
RETURNS TABLE (
  id              UUID,
  metric_type     TEXT,
  title_key       TEXT,
  description_key TEXT,
  target_value    NUMERIC,
  reward_xp       INT,
  start_at        TIMESTAMPTZ,
  end_at          TIMESTAMPTZ
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
    SELECT c.id, c.metric_type, c.title_key, c.description_key,
           c.target_value, c.reward_xp, c.start_at, c.end_at
      FROM public.challenges c
     WHERE c.is_active = true
       AND c.challenge_type = 'system'
       AND now() BETWEEN c.start_at AND c.end_at
     ORDER BY c.created_at;
END $$;
GRANT EXECUTE ON FUNCTION public.list_system_challenges() TO authenticated;

-- 6) ── RPC: list_my_challenges ─────────────────────────────────────
CREATE OR REPLACE FUNCTION public.list_my_challenges()
RETURNS TABLE (
  participant_id  UUID,
  challenge_id    UUID,
  metric_type     TEXT,
  title_key       TEXT,
  description_key TEXT,
  target_value    NUMERIC,
  progress_value  NUMERIC,
  status          TEXT,
  reward_xp       INT,
  end_at          TIMESTAMPTZ,
  joined_at       TIMESTAMPTZ,
  completed_at    TIMESTAMPTZ
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    SELECT cp.id, c.id, c.metric_type, c.title_key, c.description_key,
           c.target_value, cp.progress_value, cp.status, c.reward_xp,
           c.end_at, cp.joined_at, cp.completed_at
      FROM public.challenge_participants cp
      JOIN public.challenges c ON c.id = cp.challenge_id
     WHERE cp.user_id = v_me
     ORDER BY cp.joined_at DESC;
END $$;
GRANT EXECUTE ON FUNCTION public.list_my_challenges() TO authenticated;

-- 7) ── RPC: join_challenge ────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.join_challenge(p_challenge_id UUID)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me       UUID := auth.uid();
  v_ch       RECORD;
  v_existing TEXT;
  v_unlocked JSONB;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_ch FROM public.challenges WHERE id = p_challenge_id;
  IF NOT FOUND OR NOT v_ch.is_active OR now() > v_ch.end_at THEN
    RAISE EXCEPTION 'challenge_unavailable';
  END IF;

  SELECT status INTO v_existing FROM public.challenge_participants
   WHERE challenge_id = p_challenge_id AND user_id = v_me;
  IF v_existing = 'joined' OR v_existing = 'completed' THEN
    RAISE EXCEPTION 'already_in';
  END IF;

  INSERT INTO public.challenge_participants (challenge_id, user_id, status)
  VALUES (p_challenge_id, v_me, 'joined')
  ON CONFLICT (challenge_id, user_id) DO UPDATE
    SET status             = 'joined',
        progress_value     = 0,
        streak_current     = 0,
        last_activity_date = NULL,
        completed_at       = NULL,
        joined_at          = now();

  v_unlocked := public.check_and_unlock_achievements(v_me, 'challenge_joined');
  RETURN jsonb_build_object('ok', true, 'unlocked_achievements', v_unlocked);
END $$;
GRANT EXECUTE ON FUNCTION public.join_challenge(UUID) TO authenticated;

-- 8) ── RPC: leave_challenge ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.leave_challenge(p_challenge_id UUID)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_updated INT;
BEGIN
  UPDATE public.challenge_participants
     SET status = 'left'
   WHERE challenge_id = p_challenge_id
     AND user_id      = auth.uid()
     AND status       = 'joined';
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated = 0 THEN RAISE EXCEPTION 'not_in'; END IF;
  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.leave_challenge(UUID) TO authenticated;

-- 9) ── HELPER: process_challenge_progress ─────────────────────────
-- Invoked from triggers. Loops user's active participants, applies
-- metric-specific delta, completes & rewards atomically.
-- Reward XP applied DIRECTLY to character_stats (no apply_xp_gain
-- recursion — see TZ §"Подводные камни" #5).
CREATE OR REPLACE FUNCTION public.process_challenge_progress(
  p_user_id     UUID,
  p_event_type  TEXT,
  p_value       NUMERIC,
  p_category    TEXT  DEFAULT NULL,
  p_source_type TEXT  DEFAULT NULL,
  p_source_id   UUID  DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_p            RECORD;
  v_today        DATE    := CURRENT_DATE;
  v_delta        NUMERIC;
  v_new_progress NUMERIC;
  v_completed    BOOLEAN;
  v_new_streak   INT;
BEGIN
  FOR v_p IN
    SELECT cp.*, c.metric_type, c.target_value, c.category AS ch_category,
           c.end_at, c.reward_xp
      FROM public.challenge_participants cp
      JOIN public.challenges c ON c.id = cp.challenge_id
     WHERE cp.user_id   = p_user_id
       AND cp.status    = 'joined'
       AND c.is_active  = true
       AND now()       <= c.end_at
  LOOP
    v_delta := 0;

    CASE v_p.metric_type
      WHEN 'count' THEN
        IF p_event_type IN ('task_completed', 'habit_logged') THEN
          v_delta := 1;
        END IF;

      WHEN 'category' THEN
        IF (p_event_type = 'task_completed' OR p_event_type = 'habit_logged')
           AND p_category = v_p.ch_category THEN
          v_delta := 1;
        END IF;

      WHEN 'habit' THEN
        IF p_event_type = 'habit_logged' THEN
          v_delta := 1;
        END IF;

      WHEN 'xp' THEN
        IF p_event_type = 'xp_earned' THEN
          v_delta := p_value;
        END IF;

      WHEN 'distance' THEN
        IF p_event_type = 'health_distance' THEN
          v_delta := p_value;
        END IF;

      WHEN 'activity_day' THEN
        -- One increment per calendar day per challenge.
        IF p_event_type IN ('task_completed', 'habit_logged')
           AND v_p.last_activity_date IS DISTINCT FROM v_today THEN
          IF v_p.last_activity_date = v_today - INTERVAL '1 day' THEN
            v_new_streak := v_p.streak_current + 1;
          ELSE
            v_new_streak := 1;
          END IF;
          UPDATE public.challenge_participants
             SET last_activity_date = v_today,
                 streak_current     = v_new_streak
           WHERE id = v_p.id;
          v_delta := 1;
        END IF;

      WHEN 'streak' THEN
        -- target_value = required streak length; progress = current streak.
        IF p_event_type IN ('task_completed', 'habit_logged')
           AND v_p.last_activity_date IS DISTINCT FROM v_today THEN
          IF v_p.last_activity_date = v_today - INTERVAL '1 day' THEN
            v_new_streak := v_p.streak_current + 1;
          ELSE
            v_new_streak := 1;
          END IF;
          UPDATE public.challenge_participants
             SET last_activity_date = v_today,
                 streak_current     = v_new_streak,
                 progress_value     = v_new_streak
           WHERE id = v_p.id;
          -- Skip the generic delta path — we set progress_value directly.
          v_new_progress := v_new_streak;
          v_completed    := v_new_progress >= v_p.target_value;

          INSERT INTO public.challenge_events
            (challenge_id, user_id, event_type, value_delta, source_type, source_id)
          VALUES
            (v_p.challenge_id, p_user_id, p_event_type, 1, p_source_type, p_source_id);

          IF v_completed THEN
            UPDATE public.challenge_participants
               SET status       = 'completed',
                   completed_at = now()
             WHERE id = v_p.id;
            IF v_p.reward_xp > 0 THEN
              UPDATE public.character_stats
                 SET xp_total   = xp_total   + v_p.reward_xp,
                     xp_current = xp_current + v_p.reward_xp,
                     updated_at = now()
               WHERE user_id = p_user_id;
            END IF;
            PERFORM public.check_and_unlock_achievements(p_user_id, 'challenge_completed');
          END IF;
          CONTINUE;
        END IF;

      ELSE
        v_delta := 0;
    END CASE;

    IF v_delta = 0 THEN CONTINUE; END IF;

    v_new_progress := v_p.progress_value + v_delta;
    v_completed    := v_new_progress >= v_p.target_value;

    UPDATE public.challenge_participants
       SET progress_value = v_new_progress,
           status         = CASE WHEN v_completed THEN 'completed' ELSE 'joined' END,
           completed_at   = CASE WHEN v_completed THEN now() ELSE NULL END
     WHERE id = v_p.id;

    INSERT INTO public.challenge_events
      (challenge_id, user_id, event_type, value_delta, source_type, source_id)
    VALUES
      (v_p.challenge_id, p_user_id, p_event_type, v_delta, p_source_type, p_source_id);

    IF v_completed THEN
      IF v_p.reward_xp > 0 THEN
        UPDATE public.character_stats
           SET xp_total   = xp_total   + v_p.reward_xp,
               xp_current = xp_current + v_p.reward_xp,
               updated_at = now()
         WHERE user_id = p_user_id;
      END IF;
      PERFORM public.check_and_unlock_achievements(p_user_id, 'challenge_completed');
    END IF;
  END LOOP;
END $$;

-- 10) ── Triggers: task_logs + habit_logs → process_progress ───────
CREATE OR REPLACE FUNCTION public.tg_challenge_on_task_log()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_cat TEXT;
BEGIN
  IF NEW.action <> 'completed' THEN RETURN NEW; END IF;
  SELECT main_category::TEXT INTO v_cat FROM public.tasks WHERE id = NEW.task_id;
  PERFORM public.process_challenge_progress(
    NEW.user_id, 'task_completed', 1, v_cat, 'task', NEW.task_id
  );
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_tl_challenge ON public.task_logs;
CREATE TRIGGER tg_tl_challenge
  AFTER INSERT ON public.task_logs
  FOR EACH ROW EXECUTE FUNCTION public.tg_challenge_on_task_log();

CREATE OR REPLACE FUNCTION public.tg_challenge_on_habit_log()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_cat TEXT;
BEGIN
  SELECT main_category::TEXT INTO v_cat FROM public.habits WHERE id = NEW.habit_id;
  PERFORM public.process_challenge_progress(
    NEW.user_id, 'habit_logged', 1, v_cat, 'habit', NEW.habit_id
  );
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_hl_challenge ON public.habit_logs;
CREATE TRIGGER tg_hl_challenge
  AFTER INSERT ON public.habit_logs
  FOR EACH ROW EXECUTE FUNCTION public.tg_challenge_on_habit_log();

-- Phase 15 will add a similar trigger on health_daily_summaries.

-- 11) ── Updated check_and_unlock_achievements ─────────────────────
-- challenge_joined / challenge_completed now read real counts.
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

      -- ✨ Phase 14: real counts.
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
        NULL;
      END;
    END IF;
  END LOOP;

  RETURN v_unlocked;
END $$;
