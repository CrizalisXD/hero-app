-- ════════════════════════════════════════════════════════════════════
-- Hero — 0007_social_lite.sql  (Phase 13)
--
-- Adds:
--   - 6 tables: user_public_profiles, friend_requests, friendships,
--               activity_feed_events, user_blocks, user_reports
--   - 8 RPCs: search_users, get_public_profile, send_friend_request,
--             accept_friend_request, decline_friend_request,
--             cancel_friend_request, remove_friendship, block_user,
--             report_user, list_my_friends, list_pending_requests,
--             list_friends_feed
--   - Helper: generate_unique_username (hero_xxxxxxxx)
--   - Helper: is_blocked_between (STABLE)
--   - Trigger tg_ua_emit_feed → activity_feed_events on achievement unlock
--   - Updated ensure_user_bootstrap → creates user_public_profiles row
--   - Updated check_and_unlock_achievements → friend_count real count
--   - Backfill: public_profile rows for existing users
-- ════════════════════════════════════════════════════════════════════

-- 1) ── user_public_profiles ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_public_profiles (
  user_id            UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  username           TEXT UNIQUE,
  display_name       TEXT NOT NULL DEFAULT 'Hero',
  avatar_preview_url TEXT,
  bio                TEXT,
  public_level       INT NOT NULL DEFAULT 1,
  public_title       TEXT,
  is_searchable      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_pp_username ON public.user_public_profiles (username);
CREATE INDEX IF NOT EXISTS idx_pp_searchable ON public.user_public_profiles (is_searchable);
DROP TRIGGER IF EXISTS tg_pp_updated_at ON public.user_public_profiles;
CREATE TRIGGER tg_pp_updated_at
  BEFORE UPDATE ON public.user_public_profiles
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();
ALTER TABLE public.user_public_profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_pp_own ON public.user_public_profiles;
CREATE POLICY p_pp_own ON public.user_public_profiles
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 2) ── friend_requests ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.friend_requests (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id   UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  status      TEXT NOT NULL CHECK (status IN ('pending','accepted','declined','cancelled')) DEFAULT 'pending',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (sender_id <> receiver_id),
  UNIQUE(sender_id, receiver_id)
);
CREATE INDEX IF NOT EXISTS idx_fr_receiver_pending ON public.friend_requests (receiver_id, status);
DROP TRIGGER IF EXISTS tg_fr_updated_at ON public.friend_requests;
CREATE TRIGGER tg_fr_updated_at
  BEFORE UPDATE ON public.friend_requests
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();
ALTER TABLE public.friend_requests ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_fr_view ON public.friend_requests;
CREATE POLICY p_fr_view ON public.friend_requests
  FOR SELECT USING (sender_id = auth.uid() OR receiver_id = auth.uid());

-- 3) ── friendships (normalised: user_a_id < user_b_id) ─────────────
CREATE TABLE IF NOT EXISTS public.friendships (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a_id  UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_b_id  UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (user_a_id < user_b_id),
  UNIQUE(user_a_id, user_b_id)
);
CREATE INDEX IF NOT EXISTS idx_friendships_a ON public.friendships (user_a_id);
CREATE INDEX IF NOT EXISTS idx_friendships_b ON public.friendships (user_b_id);
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_friendships_view ON public.friendships;
CREATE POLICY p_friendships_view ON public.friendships
  FOR SELECT USING (user_a_id = auth.uid() OR user_b_id = auth.uid());

-- 4) ── activity_feed_events ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.activity_feed_events (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  visibility TEXT NOT NULL CHECK (visibility IN ('private','friends','public')) DEFAULT 'friends',
  title_key  TEXT NOT NULL,
  payload    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_feed_user_created ON public.activity_feed_events (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_feed_visibility ON public.activity_feed_events (visibility);
ALTER TABLE public.activity_feed_events ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_feed_own ON public.activity_feed_events;
CREATE POLICY p_feed_own ON public.activity_feed_events
  FOR SELECT USING (user_id = auth.uid());

-- 5) ── user_blocks + user_reports ──────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_blocks (
  blocker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (blocker_id, blocked_id),
  CHECK (blocker_id <> blocked_id)
);
ALTER TABLE public.user_blocks ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_blocks_own ON public.user_blocks;
CREATE POLICY p_blocks_own ON public.user_blocks
  FOR ALL USING (blocker_id = auth.uid()) WITH CHECK (blocker_id = auth.uid());

CREATE TABLE IF NOT EXISTS public.user_reports (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reported_user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reason           TEXT NOT NULL CHECK (reason IN ('spam','harassment','inappropriate','other')),
  details          TEXT,
  status           TEXT NOT NULL DEFAULT 'open',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (reporter_id <> reported_user_id)
);
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_reports_own ON public.user_reports;
CREATE POLICY p_reports_own ON public.user_reports
  FOR INSERT WITH CHECK (reporter_id = auth.uid());

-- 6) ── Helper: generate_unique_username ────────────────────────────
CREATE OR REPLACE FUNCTION public.generate_unique_username()
RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE
  v_candidate TEXT;
  v_attempts  INT := 0;
BEGIN
  LOOP
    v_candidate := 'hero_' || substr(encode(gen_random_bytes(4), 'hex'), 1, 8);
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.user_public_profiles WHERE username = v_candidate
    );
    v_attempts := v_attempts + 1;
    IF v_attempts > 10 THEN
      v_candidate := 'hero_' || substr(encode(gen_random_bytes(8), 'hex'), 1, 16);
      EXIT;
    END IF;
  END LOOP;
  RETURN v_candidate;
END $$;

-- 7) ── Helper: is_blocked_between ──────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_blocked_between(p_user_a UUID, p_user_b UUID)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_blocks
     WHERE (blocker_id = p_user_a AND blocked_id = p_user_b)
        OR (blocker_id = p_user_b AND blocked_id = p_user_a)
  );
$$;

-- 8) ── Updated ensure_user_bootstrap: creates public profile too ──
CREATE OR REPLACE FUNCTION public.ensure_user_bootstrap()
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id      UUID := auth.uid();
  v_email        TEXT;
  v_is_guest     BOOLEAN;
  v_display_name TEXT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
  v_is_guest := v_email IS NULL OR v_email = '';
  v_display_name := COALESCE(NULLIF(split_part(v_email, '@', 1), ''), 'Hero');

  INSERT INTO public.profiles (id, email, auth_provider, is_guest, onboarding_done)
  VALUES (v_user_id, v_email,
    CASE WHEN v_is_guest THEN 'guest' ELSE 'email' END::auth_provider_type,
    v_is_guest, false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.users (id, email, display_name)
  VALUES (v_user_id, v_email, v_display_name)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO public.character_stats (user_id) VALUES (v_user_id) ON CONFLICT DO NOTHING;
  INSERT INTO public.meta_stats     (user_id) VALUES (v_user_id) ON CONFLICT DO NOTHING;
  INSERT INTO public.category_progress (user_id, category)
    SELECT v_user_id, unnest(enum_range(NULL::task_category))
    ON CONFLICT DO NOTHING;
  INSERT INTO public.avatars              (user_id) VALUES (v_user_id) ON CONFLICT DO NOTHING;
  INSERT INTO public.notification_settings(user_id) VALUES (v_user_id) ON CONFLICT DO NOTHING;

  -- ✨ Phase 13: public profile row with generated username
  INSERT INTO public.user_public_profiles (user_id, username, display_name)
  VALUES (v_user_id, public.generate_unique_username(), v_display_name)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN jsonb_build_object('ok', true, 'user_id', v_user_id, 'is_guest', v_is_guest);
END $$;

-- 9) ── RPC: search_users ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.search_users(p_query TEXT)
RETURNS TABLE (
  user_id            UUID,
  username           TEXT,
  display_name       TEXT,
  avatar_preview_url TEXT,
  public_level       INT,
  public_title       TEXT
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me UUID := auth.uid();
  v_q  TEXT;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  v_q := lower(trim(p_query));
  IF length(v_q) < 2 THEN RETURN; END IF;

  RETURN QUERY
    SELECT pp.user_id, pp.username, pp.display_name, pp.avatar_preview_url,
           pp.public_level, pp.public_title
      FROM public.user_public_profiles pp
     WHERE pp.is_searchable = true
       AND pp.user_id <> v_me
       AND NOT public.is_blocked_between(v_me, pp.user_id)
       AND (
         lower(pp.username) LIKE v_q || '%'
         OR lower(pp.display_name) LIKE '%' || v_q || '%'
       )
     LIMIT 25;
END $$;
GRANT EXECUTE ON FUNCTION public.search_users(TEXT) TO authenticated;

-- 10) ── RPC: get_public_profile ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_public_profile(p_user_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me          UUID := auth.uid();
  v_pp          RECORD;
  v_meta        RECORD;
  v_char_level  INT;
  v_ach_count   INT;
  v_show_streak BOOLEAN;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF public.is_blocked_between(v_me, p_user_id) THEN RAISE EXCEPTION 'blocked'; END IF;

  SELECT * INTO v_pp FROM public.user_public_profiles WHERE user_id = p_user_id;
  IF NOT FOUND OR NOT v_pp.is_searchable THEN RAISE EXCEPTION 'not_found'; END IF;

  SELECT * INTO v_meta FROM public.meta_stats WHERE user_id = p_user_id;
  SELECT level INTO v_char_level FROM public.character_stats WHERE user_id = p_user_id;
  SELECT COUNT(*) INTO v_ach_count FROM public.user_achievements WHERE user_id = p_user_id;

  -- consent: show_streak (default = true if no row)
  SELECT COALESCE(granted, true) INTO v_show_streak
    FROM public.user_consents
   WHERE user_id = p_user_id AND consent_key = 'social_show_streak';
  v_show_streak := COALESCE(v_show_streak, true);

  RETURN jsonb_build_object(
    'user_id',            p_user_id,
    'username',           v_pp.username,
    'display_name',       v_pp.display_name,
    'avatar_preview_url', v_pp.avatar_preview_url,
    'public_title',       v_pp.public_title,
    'public_level',       COALESCE(v_char_level, 1),
    'streak',             CASE WHEN v_show_streak THEN COALESCE(v_meta.current_streak, 0) ELSE NULL END,
    'achievements_count', v_ach_count
  );
END $$;
GRANT EXECUTE ON FUNCTION public.get_public_profile(UUID) TO authenticated;

-- 11) ── RPC: send_friend_request ──────────────────────────────────
CREATE OR REPLACE FUNCTION public.send_friend_request(p_receiver_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me       UUID := auth.uid();
  v_count    INT;
  v_existing TEXT;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF v_me = p_receiver_id THEN RAISE EXCEPTION 'cannot_friend_self'; END IF;
  IF public.is_blocked_between(v_me, p_receiver_id) THEN RAISE EXCEPTION 'blocked'; END IF;

  -- Rate limit: 20 requests/day
  SELECT COUNT(*) INTO v_count FROM public.friend_requests
   WHERE sender_id = v_me AND created_at::date = CURRENT_DATE;
  IF v_count >= 20 THEN RAISE EXCEPTION 'rate_limited'; END IF;

  -- Already friends?
  IF EXISTS (
    SELECT 1 FROM public.friendships
     WHERE user_a_id = LEAST(v_me, p_receiver_id)
       AND user_b_id = GREATEST(v_me, p_receiver_id)
  ) THEN RAISE EXCEPTION 'already_friends'; END IF;

  -- Pending request in either direction?
  SELECT status INTO v_existing FROM public.friend_requests
   WHERE (sender_id = v_me AND receiver_id = p_receiver_id)
      OR (sender_id = p_receiver_id AND receiver_id = v_me)
   ORDER BY created_at DESC LIMIT 1;
  IF v_existing = 'pending' THEN RAISE EXCEPTION 'already_pending'; END IF;

  INSERT INTO public.friend_requests (sender_id, receiver_id)
  VALUES (v_me, p_receiver_id)
  ON CONFLICT (sender_id, receiver_id) DO UPDATE
    SET status = 'pending', updated_at = now();

  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.send_friend_request(UUID) TO authenticated;

-- 12) ── RPC: accept_friend_request ────────────────────────────────
CREATE OR REPLACE FUNCTION public.accept_friend_request(p_request_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me       UUID := auth.uid();
  v_req      RECORD;
  v_unlocked JSONB;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_req FROM public.friend_requests WHERE id = p_request_id;
  IF NOT FOUND OR v_req.receiver_id <> v_me OR v_req.status <> 'pending' THEN
    RAISE EXCEPTION 'invalid_request';
  END IF;

  UPDATE public.friend_requests
     SET status = 'accepted', updated_at = now()
   WHERE id = p_request_id;

  INSERT INTO public.friendships (user_a_id, user_b_id)
  VALUES (LEAST(v_req.sender_id, v_req.receiver_id),
          GREATEST(v_req.sender_id, v_req.receiver_id))
  ON CONFLICT DO NOTHING;

  -- Both sides may have unlocked social_first_friend.
  PERFORM public.check_and_unlock_achievements(v_req.sender_id, 'friend_added');
  v_unlocked := public.check_and_unlock_achievements(v_me, 'friend_added');

  RETURN jsonb_build_object('ok', true, 'unlocked_achievements', v_unlocked);
END $$;
GRANT EXECUTE ON FUNCTION public.accept_friend_request(UUID) TO authenticated;

-- 13) ── decline / cancel / remove ────────────────────────────────
CREATE OR REPLACE FUNCTION public.decline_friend_request(p_request_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_updated INT;
BEGIN
  UPDATE public.friend_requests
     SET status = 'declined', updated_at = now()
   WHERE id = p_request_id AND receiver_id = auth.uid() AND status = 'pending';
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated = 0 THEN RAISE EXCEPTION 'invalid_request'; END IF;
  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.decline_friend_request(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.cancel_friend_request(p_request_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_updated INT;
BEGIN
  UPDATE public.friend_requests
     SET status = 'cancelled', updated_at = now()
   WHERE id = p_request_id AND sender_id = auth.uid() AND status = 'pending';
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated = 0 THEN RAISE EXCEPTION 'invalid_request'; END IF;
  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.cancel_friend_request(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.remove_friendship(p_friend_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  DELETE FROM public.friendships
   WHERE user_a_id = LEAST(v_me, p_friend_id)
     AND user_b_id = GREATEST(v_me, p_friend_id);
  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.remove_friendship(UUID) TO authenticated;

-- 14) ── block + report ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.block_user(p_user_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me = p_user_id THEN RAISE EXCEPTION 'cannot_block_self'; END IF;

  -- Tear down existing relationship before recording the block.
  DELETE FROM public.friendships
   WHERE user_a_id = LEAST(v_me, p_user_id)
     AND user_b_id = GREATEST(v_me, p_user_id);

  UPDATE public.friend_requests
     SET status = 'cancelled', updated_at = now()
   WHERE ((sender_id = v_me AND receiver_id = p_user_id)
       OR (sender_id = p_user_id AND receiver_id = v_me))
     AND status = 'pending';

  INSERT INTO public.user_blocks (blocker_id, blocked_id)
  VALUES (v_me, p_user_id)
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.block_user(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.report_user(
  p_user_id UUID,
  p_reason  TEXT,
  p_details TEXT DEFAULT NULL
)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me    UUID := auth.uid();
  v_count INT;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF v_me = p_user_id THEN RAISE EXCEPTION 'cannot_report_self'; END IF;

  -- Rate limit: 5 reports/day
  SELECT COUNT(*) INTO v_count FROM public.user_reports
   WHERE reporter_id = v_me AND created_at::date = CURRENT_DATE;
  IF v_count >= 5 THEN RAISE EXCEPTION 'rate_limited'; END IF;

  INSERT INTO public.user_reports (reporter_id, reported_user_id, reason, details)
  VALUES (v_me, p_user_id, p_reason, p_details);

  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.report_user(UUID, TEXT, TEXT) TO authenticated;

-- 15) ── list_my_friends + list_pending_requests ─────────────────
CREATE OR REPLACE FUNCTION public.list_my_friends()
RETURNS TABLE (
  friend_user_id        UUID,
  username              TEXT,
  display_name          TEXT,
  avatar_preview_url    TEXT,
  public_level          INT,
  friendship_created_at TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    SELECT
      CASE WHEN f.user_a_id = v_me THEN f.user_b_id ELSE f.user_a_id END,
      pp.username, pp.display_name, pp.avatar_preview_url, pp.public_level,
      f.created_at
    FROM public.friendships f
    JOIN public.user_public_profiles pp
      ON pp.user_id = CASE WHEN f.user_a_id = v_me THEN f.user_b_id ELSE f.user_a_id END
   WHERE f.user_a_id = v_me OR f.user_b_id = v_me
   ORDER BY f.created_at DESC;
END $$;
GRANT EXECUTE ON FUNCTION public.list_my_friends() TO authenticated;

CREATE OR REPLACE FUNCTION public.list_pending_requests()
RETURNS TABLE (
  request_id                UUID,
  sender_id                 UUID,
  sender_username           TEXT,
  sender_display_name       TEXT,
  sender_avatar_preview_url TEXT,
  created_at                TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
    SELECT fr.id, fr.sender_id, pp.username, pp.display_name,
           pp.avatar_preview_url, fr.created_at
      FROM public.friend_requests fr
      JOIN public.user_public_profiles pp ON pp.user_id = fr.sender_id
     WHERE fr.receiver_id = auth.uid() AND fr.status = 'pending'
     ORDER BY fr.created_at DESC;
END $$;
GRANT EXECUTE ON FUNCTION public.list_pending_requests() TO authenticated;

-- 16) ── list_friends_feed ───────────────────────────────────────
CREATE OR REPLACE FUNCTION public.list_friends_feed(p_limit INT DEFAULT 50)
RETURNS TABLE (
  event_id     UUID,
  user_id      UUID,
  username     TEXT,
  display_name TEXT,
  event_type   TEXT,
  title_key    TEXT,
  payload      JSONB,
  created_at   TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    WITH friend_ids AS (
      SELECT CASE WHEN user_a_id = v_me THEN user_b_id ELSE user_a_id END AS uid
        FROM public.friendships
       WHERE user_a_id = v_me OR user_b_id = v_me
    )
    SELECT e.id, e.user_id, pp.username, pp.display_name,
           e.event_type, e.title_key, e.payload, e.created_at
      FROM public.activity_feed_events e
      JOIN friend_ids f                  ON f.uid = e.user_id
      JOIN public.user_public_profiles pp ON pp.user_id = e.user_id
     WHERE e.visibility IN ('friends','public')
     ORDER BY e.created_at DESC
     LIMIT p_limit;
END $$;
GRANT EXECUTE ON FUNCTION public.list_friends_feed(INT) TO authenticated;

-- 17) ── TRIGGER: emit feed event when achievement is unlocked ──
CREATE OR REPLACE FUNCTION public.tg_emit_feed_on_achievement()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_show BOOLEAN;
  v_ach  RECORD;
BEGIN
  -- Honour social_show_achievements consent (default = true).
  SELECT COALESCE(granted, true) INTO v_show
    FROM public.user_consents
   WHERE user_id = NEW.user_id AND consent_key = 'social_show_achievements';
  v_show := COALESCE(v_show, true);
  IF NOT v_show THEN RETURN NEW; END IF;

  SELECT * INTO v_ach FROM public.achievements WHERE id = NEW.achievement_id;

  INSERT INTO public.activity_feed_events
    (user_id, event_type, visibility, title_key, payload)
  VALUES (
    NEW.user_id,
    'achievement_unlocked',
    'friends',
    'feedAchievementUnlocked',
    jsonb_build_object(
      'achievement_id',        NEW.achievement_id,
      'achievement_title_key', v_ach.title_key,
      'rarity',                v_ach.rarity
    )
  );
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS tg_ua_emit_feed ON public.user_achievements;
CREATE TRIGGER tg_ua_emit_feed
  AFTER INSERT ON public.user_achievements
  FOR EACH ROW EXECUTE FUNCTION public.tg_emit_feed_on_achievement();

-- 18) ── Updated check_and_unlock_achievements: friend_count works
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
        -- ✨ Phase 13: real friendship count
        SELECT COUNT(*)::NUMERIC INTO v_current
          FROM public.friendships
         WHERE user_a_id = p_user_id OR user_b_id = p_user_id;
        v_meets := v_current >= v_achievement.condition_value;

      WHEN 'challenge_joined', 'challenge_completed' THEN
        v_meets := false;  -- Phase 14

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

-- 19) ── Backfill public profiles for existing users ───────────────
INSERT INTO public.user_public_profiles (user_id, username, display_name)
SELECT u.id, public.generate_unique_username(), COALESCE(u.display_name, 'Hero')
  FROM public.users u
  LEFT JOIN public.user_public_profiles pp ON pp.user_id = u.id
 WHERE pp.user_id IS NULL;
