-- ════════════════════════════════════════════════════════════════════
-- Hero — 0001_initial_clean_schema.sql  (v1.1)
-- ════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── 1. ENUMs ──────────────────────────────────────────────────────
CREATE TYPE auth_provider_type AS ENUM ('email', 'guest');
CREATE TYPE task_category AS ENUM ('strength','mind','endurance','health','social','finance','creativity');
CREATE TYPE task_difficulty AS ENUM ('easy', 'normal', 'hard', 'epic');
CREATE TYPE task_duration AS ENUM ('short', 'medium', 'long');
CREATE TYPE task_importance AS ENUM ('low', 'normal', 'high');
CREATE TYPE task_status AS ENUM ('active', 'done', 'archived');
CREATE TYPE habit_type AS ENUM ('good', 'bad');
CREATE TYPE habit_input_type AS ENUM ('boolean', 'numeric', 'duration');
CREATE TYPE recurrence_type AS ENUM ('daily', 'weekly');
CREATE TYPE goal_status AS ENUM ('active', 'completed', 'paused', 'abandoned');
CREATE TYPE xp_source_type AS ENUM ('task','habit','milestone','daily_login','streak_milestone','bonus');
CREATE TYPE ai_message_role AS ENUM ('user', 'assistant', 'system');
CREATE TYPE ai_memory_type AS ENUM ('preference','goal_context','obstacle','routine','motivation','behavior_pattern','avatar_preference');

-- ── 2. updated_at trigger ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.tg_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END $$;

-- ── 3. USER TABLES ────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT, display_name TEXT, avatar_url TEXT,
  auth_provider auth_provider_type NOT NULL DEFAULT 'guest',
  is_guest BOOLEAN NOT NULL DEFAULT false,
  onboarding_done BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  display_name TEXT NOT NULL DEFAULT 'Hero',
  avatar_url TEXT,
  locale TEXT NOT NULL DEFAULT 'ru' CHECK (locale IN ('ru','en')),
  timezone TEXT NOT NULL DEFAULT 'UTC',
  current_life_change_areas TEXT[] NOT NULL DEFAULT '{}',
  current_main_obstacle TEXT NOT NULL DEFAULT '',
  current_energy_level INT NOT NULL DEFAULT 3 CHECK (current_energy_level BETWEEN 1 AND 5),
  current_time_commitment_minutes INT NOT NULL DEFAULT 15,
  current_failure_reasons TEXT[] NOT NULL DEFAULT '{}',
  current_support_style TEXT NOT NULL DEFAULT 'direct',
  profile_updated_at TIMESTAMPTZ,
  next_profile_checkin_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.user_profile_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  life_change_areas TEXT[] NOT NULL DEFAULT '{}',
  main_obstacle TEXT NOT NULL DEFAULT '',
  energy_level INT NOT NULL DEFAULT 3 CHECK (energy_level BETWEEN 1 AND 5),
  time_commitment_minutes INT NOT NULL DEFAULT 15,
  failure_reasons TEXT[] NOT NULL DEFAULT '{}',
  support_style TEXT NOT NULL DEFAULT 'direct',
  plan_difficulty_preference TEXT,
  source TEXT NOT NULL DEFAULT 'manual_update'
    CHECK (source IN ('onboarding','biweekly_checkin','manual_update','ai_suggested_update')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_snapshots_user_created ON public.user_profile_snapshots (user_id, created_at DESC);

-- ── 4. GAME PROGRESS ─────────────────────────────────────────────
CREATE TABLE public.character_stats (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  level INT NOT NULL DEFAULT 1,
  xp_current INT NOT NULL DEFAULT 0,
  xp_to_next INT NOT NULL DEFAULT 200,
  xp_total INT NOT NULL DEFAULT 0,
  energy INT NOT NULL DEFAULT 100,
  energy_max INT NOT NULL DEFAULT 100,
  task_slots INT NOT NULL DEFAULT 2,
  habit_slots INT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_character_stats_updated_at BEFORE UPDATE ON public.character_stats
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.categories (
  id task_category PRIMARY KEY,
  title_ru TEXT NOT NULL, title_en TEXT NOT NULL,
  description_ru TEXT, description_en TEXT,
  color TEXT NOT NULL, icon TEXT NOT NULL,
  base_xp INT NOT NULL DEFAULT 20, sort_order INT NOT NULL DEFAULT 0
);
INSERT INTO public.categories (id, title_ru, title_en, color, icon, base_xp, sort_order) VALUES
  ('strength',   'Сила',         'Strength',   '#E54B4B', 'dumbbell',    20, 1),
  ('mind',       'Разум',        'Mind',       '#5B6CFF', 'brain',       20, 2),
  ('endurance',  'Выносливость', 'Endurance',  '#23B07A', 'activity',    20, 3),
  ('health',     'Здоровье',     'Health',     '#3DC9C2', 'heart-pulse', 20, 4),
  ('social',     'Социальное',   'Social',     '#FFB547', 'users',       20, 5),
  ('finance',    'Финансы',      'Finance',    '#F2C94C', 'wallet',      20, 6),
  ('creativity', 'Творчество',   'Creativity', '#BF7CFF', 'palette',     20, 7);

CREATE TABLE public.category_progress (
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  category task_category NOT NULL,
  xp_total INT NOT NULL DEFAULT 0,
  level INT NOT NULL DEFAULT 1,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, category)
);
CREATE TRIGGER tg_category_progress_updated_at BEFORE UPDATE ON public.category_progress
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.meta_stats (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  discipline_xp INT NOT NULL DEFAULT 0,
  consistency_score INT NOT NULL DEFAULT 0 CHECK (consistency_score BETWEEN 0 AND 100),
  focus_score INT NOT NULL DEFAULT 0 CHECK (focus_score BETWEEN 0 AND 100),
  current_streak INT NOT NULL DEFAULT 0,
  best_streak INT NOT NULL DEFAULT 0,
  last_active_date DATE,
  coins INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_meta_stats_updated_at BEFORE UPDATE ON public.meta_stats
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- ── 5. TASKS / HABITS / GOALS ─────────────────────────────────────
CREATE TABLE public.goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL, description TEXT,
  main_category task_category NOT NULL DEFAULT 'mind',
  secondary_categories task_category[] NOT NULL DEFAULT '{}',
  difficulty task_difficulty NOT NULL DEFAULT 'normal',
  duration task_duration NOT NULL DEFAULT 'medium',
  importance task_importance NOT NULL DEFAULT 'normal',
  status goal_status NOT NULL DEFAULT 'active',
  target_date DATE,
  ai_generated BOOLEAN NOT NULL DEFAULT false,
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_goals_user_status ON public.goals (user_id, status) WHERE is_deleted = false;
CREATE TRIGGER tg_goals_updated_at BEFORE UPDATE ON public.goals
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  goal_id UUID REFERENCES public.goals(id) ON DELETE SET NULL,
  title TEXT NOT NULL, description TEXT,
  main_category task_category NOT NULL DEFAULT 'mind',
  secondary_categories task_category[] NOT NULL DEFAULT '{}',
  difficulty task_difficulty NOT NULL DEFAULT 'normal',
  duration task_duration NOT NULL DEFAULT 'medium',
  importance task_importance NOT NULL DEFAULT 'normal',
  xp_reward INT NOT NULL DEFAULT 20,
  discipline_xp_reward INT NOT NULL DEFAULT 0,
  is_done BOOLEAN NOT NULL DEFAULT false,
  is_recurring BOOLEAN NOT NULL DEFAULT false,
  recurrence recurrence_type,
  due_date DATE, completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_tasks_user_due ON public.tasks (user_id, due_date);
CREATE INDEX idx_tasks_user_done ON public.tasks (user_id, is_done);
CREATE INDEX idx_tasks_goal ON public.tasks (goal_id) WHERE goal_id IS NOT NULL;
CREATE TRIGGER tg_tasks_updated_at BEFORE UPDATE ON public.tasks
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
  action TEXT NOT NULL CHECK (action IN ('created','completed','uncompleted','edited','deleted')),
  xp_earned INT NOT NULL DEFAULT 0,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_task_logs_user_created ON public.task_logs (user_id, created_at DESC);

CREATE TABLE public.habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  goal_id UUID REFERENCES public.goals(id) ON DELETE SET NULL,
  title TEXT NOT NULL, description TEXT,
  type habit_type NOT NULL DEFAULT 'good',
  input_type habit_input_type NOT NULL DEFAULT 'boolean',
  recurrence recurrence_type NOT NULL DEFAULT 'daily',
  target_value INT NOT NULL DEFAULT 1, unit TEXT,
  main_category task_category NOT NULL DEFAULT 'mind',
  secondary_categories task_category[] NOT NULL DEFAULT '{}',
  difficulty task_difficulty NOT NULL DEFAULT 'normal',
  duration task_duration NOT NULL DEFAULT 'medium',
  importance task_importance NOT NULL DEFAULT 'normal',
  xp_reward INT NOT NULL DEFAULT 20,
  discipline_xp_reward INT NOT NULL DEFAULT 0,
  current_streak INT NOT NULL DEFAULT 0,
  best_streak INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_habits_user_archived ON public.habits (user_id, is_archived);
CREATE TRIGGER tg_habits_updated_at BEFORE UPDATE ON public.habits
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.habit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  log_date DATE NOT NULL DEFAULT CURRENT_DATE,
  value INT NOT NULL DEFAULT 1,
  xp_earned INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(habit_id, log_date)
);
CREATE INDEX idx_habit_logs_user_date ON public.habit_logs (user_id, log_date DESC);

CREATE TABLE public.milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES public.goals(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL, description TEXT,
  xp_reward INT NOT NULL DEFAULT 50, reward_item TEXT,
  is_done BOOLEAN NOT NULL DEFAULT false,
  target_date DATE, completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_milestones_goal ON public.milestones (goal_id);

-- ── 6. XP LEDGER ──────────────────────────────────────────────────
CREATE TABLE public.xp_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  source_type xp_source_type NOT NULL,
  source_id UUID, category task_category,
  xp_amount INT NOT NULL DEFAULT 0,
  discipline_xp_amount INT NOT NULL DEFAULT 0,
  log_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX uq_xp_ledger_replay ON public.xp_ledger (
  user_id, source_type,
  COALESCE(source_id, '00000000-0000-0000-0000-000000000000'::uuid),
  log_date
);
CREATE INDEX idx_xp_ledger_user_date ON public.xp_ledger (user_id, log_date DESC);

-- ── 7. AI ──────────────────────────────────────────────────────────
CREATE TABLE public.ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT, context_type TEXT NOT NULL DEFAULT 'general',
  is_archived BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_ai_conversations_updated_at BEFORE UPDATE ON public.ai_conversations
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.ai_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.ai_conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role ai_message_role NOT NULL, content TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ai_messages_conv_created ON public.ai_messages (conversation_id, created_at);

CREATE TABLE public.ai_memory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  memory_type ai_memory_type NOT NULL, content TEXT NOT NULL,
  confidence REAL NOT NULL DEFAULT 0.7 CHECK (confidence BETWEEN 0 AND 1),
  source TEXT NOT NULL DEFAULT 'chat',
  last_used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ai_memory_user_type ON public.ai_memory (user_id, memory_type);
CREATE TRIGGER tg_ai_memory_updated_at BEFORE UPDATE ON public.ai_memory
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.ai_request_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  feature TEXT NOT NULL,
  tokens_input INT NOT NULL DEFAULT 0,
  tokens_output INT NOT NULL DEFAULT 0,
  request_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_ai_logs_user_date ON public.ai_request_logs (user_id, request_date);

-- ── 8. AVATAR ──────────────────────────────────────────────────────
CREATE TABLE public.avatars (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  renderer TEXT NOT NULL DEFAULT 'placeholder',
  body_type TEXT NOT NULL DEFAULT 'default',
  face_type TEXT NOT NULL DEFAULT 'default',
  hair_type TEXT NOT NULL DEFAULT 'default',
  clothing_type TEXT NOT NULL DEFAULT 'default',
  primary_color TEXT NOT NULL DEFAULT '#7F77DD',
  mesh_url TEXT, face_texture_url TEXT, unity_avatar_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_avatars_updated_at BEFORE UPDATE ON public.avatars
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- ── 9. v1.1 ЗАГОТОВКИ ────────────────────────────────────────────
CREATE TABLE public.user_consents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  consent_key TEXT NOT NULL,
  granted BOOLEAN NOT NULL DEFAULT false,
  source TEXT NOT NULL DEFAULT 'settings',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, consent_key)
);
CREATE TRIGGER tg_user_consents_updated_at BEFORE UPDATE ON public.user_consents
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.feature_flags (
  key TEXT PRIMARY KEY,
  enabled BOOLEAN NOT NULL DEFAULT false,
  rollout_percent INT NOT NULL DEFAULT 0 CHECK (rollout_percent BETWEEN 0 AND 100),
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_feature_flags_updated_at BEFORE UPDATE ON public.feature_flags
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

INSERT INTO public.feature_flags (key, enabled) VALUES
  ('social_enabled', false),
  ('challenges_enabled', false),
  ('rewards_enabled', false),
  ('siri_shortcuts_enabled', false),
  ('health_integration_enabled', false),
  ('calendar_integration_enabled', false),
  ('notes_enabled', false),
  ('unity_avatar_enabled', false),
  ('photo_avatar_generation_enabled', false),
  ('external_integrations_enabled', false);

CREATE TABLE public.user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL CHECK (platform IN ('ios','android')),
  fcm_token TEXT, apns_token TEXT, device_name TEXT, locale TEXT, timezone TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_user_devices_user_active ON public.user_devices (user_id, is_active);
CREATE TRIGGER tg_user_devices_updated_at BEFORE UPDATE ON public.user_devices
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

CREATE TABLE public.notification_settings (
  user_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
  tasks_enabled BOOLEAN NOT NULL DEFAULT true,
  habits_enabled BOOLEAN NOT NULL DEFAULT true,
  ai_coach_enabled BOOLEAN NOT NULL DEFAULT true,
  social_enabled BOOLEAN NOT NULL DEFAULT true,
  challenges_enabled BOOLEAN NOT NULL DEFAULT true,
  quiet_hours_enabled BOOLEAN NOT NULL DEFAULT true,
  quiet_hours_start TIME DEFAULT '22:00',
  quiet_hours_end TIME DEFAULT '08:00',
  timezone TEXT NOT NULL DEFAULT 'UTC',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE TRIGGER tg_notification_settings_updated_at BEFORE UPDATE ON public.notification_settings
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- ── 10. RLS ────────────────────────────────────────────────────────
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_profile_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.character_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.category_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.meta_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.xp_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_memory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_request_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.avatars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY p_profiles_own ON public.profiles FOR ALL USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY p_users_own ON public.users FOR ALL USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY p_character_stats_own ON public.character_stats FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_meta_stats_own ON public.meta_stats FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_avatars_own ON public.avatars FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_notification_settings_own ON public.notification_settings FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_snapshots_own ON public.user_profile_snapshots FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_category_progress_own ON public.category_progress FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_goals_own ON public.goals FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_tasks_own ON public.tasks FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_task_logs_own ON public.task_logs FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_habits_own ON public.habits FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_habit_logs_own ON public.habit_logs FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_milestones_own ON public.milestones FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_xp_ledger_own ON public.xp_ledger FOR SELECT USING (user_id = auth.uid());
CREATE POLICY p_ai_conv_own ON public.ai_conversations FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_ai_msg_own ON public.ai_messages FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_ai_mem_own ON public.ai_memory FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_ai_logs_own ON public.ai_request_logs FOR SELECT USING (user_id = auth.uid());
CREATE POLICY p_user_consents_own ON public.user_consents FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY p_user_devices_own ON public.user_devices FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- ── 11. RPC ────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.ensure_user_bootstrap()
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_email TEXT;
  v_is_guest BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT email INTO v_email FROM auth.users WHERE id = v_user_id;
  v_is_guest := v_email IS NULL OR v_email = '';
  INSERT INTO public.profiles (id, email, auth_provider, is_guest, onboarding_done)
  VALUES (v_user_id, v_email, CASE WHEN v_is_guest THEN 'guest' ELSE 'email' END::auth_provider_type, v_is_guest, false)
  ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.users (id, email, display_name) VALUES (v_user_id, v_email, 'Hero') ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.character_stats (user_id) VALUES (v_user_id) ON CONFLICT (user_id) DO NOTHING;
  INSERT INTO public.meta_stats (user_id) VALUES (v_user_id) ON CONFLICT (user_id) DO NOTHING;
  INSERT INTO public.category_progress (user_id, category) SELECT v_user_id, unnest(enum_range(NULL::task_category)) ON CONFLICT DO NOTHING;
  INSERT INTO public.avatars (user_id) VALUES (v_user_id) ON CONFLICT (user_id) DO NOTHING;
  INSERT INTO public.notification_settings (user_id) VALUES (v_user_id) ON CONFLICT (user_id) DO NOTHING;
  RETURN jsonb_build_object('ok', true, 'user_id', v_user_id, 'is_guest', v_is_guest);
END $$;
REVOKE ALL ON FUNCTION public.ensure_user_bootstrap() FROM public;
GRANT EXECUTE ON FUNCTION public.ensure_user_bootstrap() TO authenticated;

CREATE OR REPLACE FUNCTION public.calc_xp_to_next(p_level INT)
RETURNS INT LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
  RETURN GREATEST(1, ROUND(200 * power(1.5, GREATEST(0, p_level - 1)))::INT);
END $$;

CREATE OR REPLACE FUNCTION public.apply_xp_gain(p_user_id UUID, p_xp INT)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_level INT; v_current INT; v_to_next INT; v_total INT;
  v_level_before INT; v_levels_gained INT := 0;
BEGIN
  SELECT level, xp_current, xp_to_next, xp_total
    INTO v_level, v_current, v_to_next, v_total
  FROM public.character_stats WHERE user_id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'character_stats not found for user %', p_user_id; END IF;
  v_level_before := v_level;
  v_total := v_total + p_xp;
  v_current := v_current + p_xp;
  WHILE v_current >= v_to_next LOOP
    v_current := v_current - v_to_next;
    v_level := v_level + 1;
    v_levels_gained := v_levels_gained + 1;
    v_to_next := public.calc_xp_to_next(v_level);
  END LOOP;
  UPDATE public.character_stats
  SET level = v_level, xp_current = v_current, xp_to_next = v_to_next, xp_total = v_total, updated_at = now()
  WHERE user_id = p_user_id;
  RETURN jsonb_build_object('level_before', v_level_before, 'level_after', v_level, 'levels_gained', v_levels_gained,
    'xp_current', v_current, 'xp_to_next', v_to_next, 'xp_total', v_total);
END $$;

CREATE OR REPLACE FUNCTION public.complete_task(p_task_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_task public.tasks%ROWTYPE;
  v_xp INT; v_discipline INT; v_xp_total INT;
  v_xp_result JSONB; v_ledger_inserted INT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT * INTO v_task FROM public.tasks WHERE id = p_task_id AND user_id = v_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'task_not_found'; END IF;
  IF v_task.is_done THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;
  v_xp := v_task.xp_reward;
  v_discipline := v_task.discipline_xp_reward;
  v_xp_total := v_xp + v_discipline;
  INSERT INTO public.xp_ledger (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES (v_user_id, 'task', p_task_id, v_task.main_category, v_xp, v_discipline, CURRENT_DATE)
  ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay DO NOTHING;
  GET DIAGNOSTICS v_ledger_inserted = ROW_COUNT;
  IF v_ledger_inserted = 0 THEN
    UPDATE public.tasks SET is_done = true, completed_at = now(), updated_at = now() WHERE id = p_task_id;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'task_id', p_task_id);
  END IF;
  UPDATE public.tasks SET is_done = true, completed_at = now(), updated_at = now() WHERE id = p_task_id;
  INSERT INTO public.task_logs (user_id, task_id, action, xp_earned) VALUES (v_user_id, p_task_id, 'completed', v_xp_total);
  UPDATE public.category_progress
  SET xp_total = xp_total + v_xp, level = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1), updated_at = now()
  WHERE user_id = v_user_id AND category = v_task.main_category;
  UPDATE public.meta_stats SET discipline_xp = discipline_xp + v_discipline, last_active_date = CURRENT_DATE, updated_at = now()
  WHERE user_id = v_user_id;
  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);
  RETURN jsonb_build_object('ok', true, 'duplicate', false, 'task_id', p_task_id,
    'category', v_task.main_category, 'category_xp', v_xp, 'discipline_xp', v_discipline,
    'xp_total_gained', v_xp_total, 'character', v_xp_result);
END $$;
REVOKE ALL ON FUNCTION public.complete_task(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_task(UUID) TO authenticated;

CREATE OR REPLACE FUNCTION public.complete_habit_checkin(p_habit_id UUID, p_value INT DEFAULT 1)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_habit public.habits%ROWTYPE;
  v_today DATE := CURRENT_DATE;
  v_yesterday DATE := CURRENT_DATE - INTERVAL '1 day';
  v_was_yesterday BOOLEAN;
  v_new_streak INT; v_xp INT; v_discipline INT; v_xp_total INT;
  v_xp_result JSONB; v_inserted INT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT * INTO v_habit FROM public.habits WHERE id = p_habit_id AND user_id = v_user_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;
  INSERT INTO public.habit_logs (habit_id, user_id, log_date, value, xp_earned)
  VALUES (p_habit_id, v_user_id, v_today, p_value, v_habit.xp_reward + v_habit.discipline_xp_reward)
  ON CONFLICT (habit_id, log_date) DO NOTHING;
  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;
  SELECT EXISTS(SELECT 1 FROM public.habit_logs WHERE habit_id = p_habit_id AND log_date = v_yesterday) INTO v_was_yesterday;
  v_new_streak := CASE WHEN v_was_yesterday THEN v_habit.current_streak + 1 ELSE 1 END;
  UPDATE public.habits SET current_streak = v_new_streak, best_streak = GREATEST(best_streak, v_new_streak), updated_at = now()
  WHERE id = p_habit_id;
  v_xp := v_habit.xp_reward;
  v_discipline := v_habit.discipline_xp_reward;
  v_xp_total := v_xp + v_discipline;
  INSERT INTO public.xp_ledger (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES (v_user_id, 'habit', p_habit_id, v_habit.main_category, v_xp, v_discipline, v_today)
  ON CONFLICT ON CONSTRAINT uq_xp_ledger_replay DO NOTHING;
  UPDATE public.category_progress
  SET xp_total = xp_total + v_xp, level = GREATEST(1, FLOOR((xp_total + v_xp) / 200.0)::INT + 1), updated_at = now()
  WHERE user_id = v_user_id AND category = v_habit.main_category;
  UPDATE public.meta_stats
  SET discipline_xp = discipline_xp + v_discipline, current_streak = GREATEST(current_streak, v_new_streak),
      best_streak = GREATEST(best_streak, v_new_streak), last_active_date = v_today, updated_at = now()
  WHERE user_id = v_user_id;
  v_xp_result := public.apply_xp_gain(v_user_id, v_xp_total);
  RETURN jsonb_build_object('ok', true, 'duplicate', false, 'habit_id', p_habit_id,
    'category', v_habit.main_category, 'category_xp', v_xp, 'discipline_xp', v_discipline,
    'current_streak', v_new_streak, 'character', v_xp_result);
END $$;
REVOKE ALL ON FUNCTION public.complete_habit_checkin(UUID, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_habit_checkin(UUID, INT) TO authenticated;

CREATE OR REPLACE FUNCTION public.goal_progress_me(p_goal_id UUID)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_goal public.goals%ROWTYPE;
  v_tasks_total INT; v_tasks_done INT;
  v_habits_total INT;
  v_milestones_total INT; v_milestones_done INT;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  SELECT * INTO v_goal FROM public.goals WHERE id = p_goal_id AND user_id = v_user_id AND is_deleted = false;
  IF NOT FOUND THEN RAISE EXCEPTION 'goal_not_found'; END IF;
  SELECT COUNT(*) FILTER (WHERE TRUE), COUNT(*) FILTER (WHERE is_done = true)
    INTO v_tasks_total, v_tasks_done FROM public.tasks WHERE goal_id = p_goal_id;
  SELECT COUNT(*) INTO v_habits_total FROM public.habits WHERE goal_id = p_goal_id AND is_archived = false;
  SELECT COUNT(*) FILTER (WHERE TRUE), COUNT(*) FILTER (WHERE is_done = true)
    INTO v_milestones_total, v_milestones_done FROM public.milestones WHERE goal_id = p_goal_id;
  RETURN jsonb_build_object(
    'goal_id', p_goal_id, 'status', v_goal.status,
    'tasks_total', v_tasks_total, 'tasks_done', v_tasks_done,
    'tasks_progress', CASE WHEN v_tasks_total > 0 THEN v_tasks_done::FLOAT / v_tasks_total ELSE 0 END,
    'habits_total', v_habits_total,
    'milestones_total', v_milestones_total, 'milestones_done', v_milestones_done,
    'milestones_progress', CASE WHEN v_milestones_total > 0 THEN v_milestones_done::FLOAT / v_milestones_total ELSE 0 END
  );
END $$;
REVOKE ALL ON FUNCTION public.goal_progress_me(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.goal_progress_me(UUID) TO authenticated;

-- ════════════════════════════════════════════════════════════════════
-- END OF MIGRATION
-- ════════════════════════════════════════════════════════════════════
