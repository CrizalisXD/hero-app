-- ════════════════════════════════════════════════════════════════════
-- Hero — 0002_onboarding_rpc.sql
-- Atomic onboarding bootstrap RPC.
-- Called exclusively by the `onboarding-bootstrap` Edge Function.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.onboarding_bootstrap(p_payload JSONB)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id            UUID    := auth.uid();
  v_life_areas         TEXT[];
  v_main_obstacle      TEXT;
  v_energy_level       INT;
  v_time_commitment    INT;
  v_failure_reasons    TEXT[];
  v_support_style      TEXT;
  v_starter_habit_keys TEXT[];
  v_habits_created     INT     := 0;
  v_already_done       BOOLEAN := false;
  v_locale             TEXT    := 'en';
BEGIN
  -- ── Auth guard ────────────────────────────────────────────────────
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- ── Idempotency: already bootstrapped → return early ─────────────
  SELECT onboarding_done INTO v_already_done
    FROM public.profiles
   WHERE id = v_user_id;

  IF v_already_done IS TRUE THEN
    RETURN jsonb_build_object(
      'ok',                  true,
      'onboarding_done',     true,
      'already_bootstrapped', true,
      'habits_created',      0
    );
  END IF;

  -- ── Extract & sanitise payload ────────────────────────────────────
  v_life_areas      := ARRAY(
                         SELECT jsonb_array_elements_text(p_payload -> 'life_change_areas')
                       );
  v_main_obstacle   := COALESCE(p_payload ->> 'main_obstacle', '');
  v_energy_level    := GREATEST(1, LEAST(5,
                         COALESCE((p_payload ->> 'energy_level')::INT, 3)
                       ));
  v_time_commitment := GREATEST(5, LEAST(120,
                         COALESCE((p_payload ->> 'time_commitment_minutes')::INT, 15)
                       ));
  v_failure_reasons := ARRAY(
                         SELECT jsonb_array_elements_text(p_payload -> 'failure_reasons')
                       );
  v_support_style   := COALESCE(p_payload ->> 'support_style', 'direct');
  v_starter_habit_keys := ARRAY(
                            SELECT jsonb_array_elements_text(p_payload -> 'starter_habits')
                          );

  -- Detect user locale for localised habit titles
  SELECT locale INTO v_locale
    FROM public.users
   WHERE id = v_user_id;
  v_locale := COALESCE(v_locale, 'en');

  -- ── 1. Update users current profile data ─────────────────────────
  UPDATE public.users
     SET current_life_change_areas    = v_life_areas,
         current_main_obstacle        = v_main_obstacle,
         current_energy_level         = v_energy_level,
         current_time_commitment_minutes = v_time_commitment,
         current_failure_reasons      = v_failure_reasons,
         current_support_style        = v_support_style,
         profile_updated_at           = now(),
         updated_at                   = now()
   WHERE id = v_user_id;

  -- ── 2. Insert profile snapshot ────────────────────────────────────
  INSERT INTO public.user_profile_snapshots (
    user_id,
    life_change_areas,
    main_obstacle,
    energy_level,
    time_commitment_minutes,
    failure_reasons,
    support_style,
    source
  ) VALUES (
    v_user_id,
    v_life_areas,
    v_main_obstacle,
    v_energy_level,
    v_time_commitment,
    v_failure_reasons,
    v_support_style,
    'onboarding'
  );

  -- ── 3. Insert starter habits atomically ───────────────────────────
  IF 'drink_water' = ANY(v_starter_habit_keys) THEN
    INSERT INTO public.habits (
      user_id, title, type, input_type, recurrence,
      main_category, difficulty, duration, importance,
      xp_reward, discipline_xp_reward
    ) VALUES (
      v_user_id,
      CASE WHEN v_locale = 'ru' THEN 'Пить воду утром' ELSE 'Drink water in the morning' END,
      'good', 'boolean', 'daily',
      'health', 'easy', 'short', 'normal',
      10, 5
    );
    v_habits_created := v_habits_created + 1;
  END IF;

  IF 'read_10_pages' = ANY(v_starter_habit_keys) THEN
    INSERT INTO public.habits (
      user_id, title, type, input_type, recurrence,
      main_category, difficulty, duration, importance,
      xp_reward, discipline_xp_reward
    ) VALUES (
      v_user_id,
      CASE WHEN v_locale = 'ru' THEN 'Читать 10 страниц' ELSE 'Read 10 pages' END,
      'good', 'boolean', 'daily',
      'mind', 'easy', 'medium', 'normal',
      15, 5
    );
    v_habits_created := v_habits_created + 1;
  END IF;

  IF 'walk_10_min' = ANY(v_starter_habit_keys) THEN
    INSERT INTO public.habits (
      user_id, title, type, input_type, recurrence,
      main_category, difficulty, duration, importance,
      xp_reward, discipline_xp_reward
    ) VALUES (
      v_user_id,
      CASE WHEN v_locale = 'ru' THEN 'Прогулка 10 минут' ELSE 'Walk 10 minutes' END,
      'good', 'boolean', 'daily',
      'endurance', 'easy', 'short', 'normal',
      10, 5
    );
    v_habits_created := v_habits_created + 1;
  END IF;

  -- ── 4. Finalise: mark onboarding done (last step in transaction) ──
  UPDATE public.profiles
     SET onboarding_done = true,
         updated_at      = now()
   WHERE id = v_user_id;

  RETURN jsonb_build_object(
    'ok',                  true,
    'onboarding_done',     true,
    'already_bootstrapped', false,
    'habits_created',      v_habits_created
  );
END $$;

-- ── Permissions ───────────────────────────────────────────────────────
-- Callable by authenticated users via the Edge Function.
-- The SECURITY DEFINER + auth.uid() guard ensures users can only
-- bootstrap their own data. The Edge Function validates allowlists
-- before the RPC is reached.
REVOKE ALL ON FUNCTION public.onboarding_bootstrap(JSONB) FROM public;
REVOKE ALL ON FUNCTION public.onboarding_bootstrap(JSONB) FROM anon;
GRANT EXECUTE ON FUNCTION public.onboarding_bootstrap(JSONB) TO authenticated;
