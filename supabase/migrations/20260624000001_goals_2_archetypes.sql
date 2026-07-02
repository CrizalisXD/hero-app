-- ════════════════════════════════════════════════════════════════════
-- Hero — 20260624000001_goals_2_archetypes.sql
-- Phase 19 — Goals 2.0: archetypes, plan periods, plan modes.
-- Additive only — every new column is nullable / defaulted, so existing
-- goals keep working ('custom' archetype, 'ai' plan_mode, 30-day period).
-- ════════════════════════════════════════════════════════════════════

-- New enum for goal archetypes
DO $$ BEGIN
  CREATE TYPE goal_archetype AS ENUM (
    'skill_learning',
    'habit_building',
    'fitness_health',
    'project_creation',
    'money_purchase',
    'event_preparation',
    'relationship_goal',
    'life_change',
    'custom'
  );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- New enum for plan mode
DO $$ BEGIN
  CREATE TYPE goal_plan_mode AS ENUM ('ai', 'own', 'mixed');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- New goal status value
ALTER TYPE goal_status ADD VALUE IF NOT EXISTS 'extended';

-- Extend the goals table
ALTER TABLE goals
  ADD COLUMN IF NOT EXISTS archetype        goal_archetype DEFAULT 'custom',
  ADD COLUMN IF NOT EXISTS plan_mode        goal_plan_mode DEFAULT 'ai',
  ADD COLUMN IF NOT EXISTS plan_period_days INT            DEFAULT 30;

-- Index for archetype filtering (future analytics / recommendations)
CREATE INDEX IF NOT EXISTS idx_goals_archetype ON goals(archetype);

-- ── Update create_goal_with_plan RPC ─────────────────────────────────
-- Persist archetype / plan_mode / plan_period_days, and derive
-- target_date from plan_period_days when the caller doesn't supply one.
-- Backward-compatible: callers that omit the new keys get the defaults.
CREATE OR REPLACE FUNCTION public.create_goal_with_plan(p_payload JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id      UUID := auth.uid();
  v_goal_id      UUID;
  v_title        TEXT;
  v_desc         TEXT;
  v_main         task_category;
  v_secondaries  task_category[];
  v_difficulty   task_difficulty;
  v_duration     task_duration;
  v_importance   task_importance;
  v_target_date  DATE;
  v_archetype    goal_archetype;
  v_plan_mode    goal_plan_mode;
  v_period_days  INT;

  v_step              JSONB;
  v_type              TEXT;
  v_step_category     task_category;
  v_inserted_tasks      INT := 0;
  v_inserted_habits     INT := 0;
  v_inserted_milestones INT := 0;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- ── Parse goal-level fields ───────────────────────────────────────
  v_title       := COALESCE(trim(p_payload->>'goal_title'), '');
  v_desc        := NULLIF(trim(COALESCE(p_payload->>'goal_description', '')), '');
  v_main        := (COALESCE(NULLIF(p_payload->>'main_category', ''), 'mind'))::task_category;
  v_secondaries := COALESCE(
    (SELECT array_agg(x::task_category)
     FROM jsonb_array_elements_text(p_payload->'secondary_categories') AS x
     WHERE x <> p_payload->>'main_category'),
    '{}'::task_category[]
  );
  v_difficulty  := (COALESCE(NULLIF(p_payload->>'difficulty', ''), 'normal'))::task_difficulty;
  v_duration    := (COALESCE(NULLIF(p_payload->>'duration', ''),  'medium'))::task_duration;
  v_importance  := (COALESCE(NULLIF(p_payload->>'importance', ''), 'normal'))::task_importance;

  -- Phase 19: archetype / plan_mode / plan_period_days
  BEGIN
    v_archetype := (COALESCE(NULLIF(p_payload->>'archetype', ''), 'custom'))::goal_archetype;
  EXCEPTION WHEN invalid_text_representation THEN
    v_archetype := 'custom';
  END;
  BEGIN
    v_plan_mode := (COALESCE(NULLIF(p_payload->>'plan_mode', ''), 'ai'))::goal_plan_mode;
  EXCEPTION WHEN invalid_text_representation THEN
    v_plan_mode := 'ai';
  END;
  v_period_days := GREATEST(1, LEAST(730, COALESCE((p_payload->>'plan_period_days')::INT, 30)));

  -- target_date: explicit value wins, otherwise derive from the period.
  v_target_date := NULLIF(p_payload->>'target_date', '')::DATE;
  IF v_target_date IS NULL THEN
    v_target_date := (CURRENT_DATE + (v_period_days * INTERVAL '1 day'))::DATE;
  END IF;

  IF length(v_title) < 2 THEN
    RAISE EXCEPTION 'invalid_title: goal_title must be at least 2 chars';
  END IF;

  -- ── 1. Create goal ────────────────────────────────────────────────
  INSERT INTO public.goals (
    user_id, title, description,
    main_category, secondary_categories,
    difficulty, duration, importance,
    status, target_date, ai_generated,
    archetype, plan_mode, plan_period_days
  ) VALUES (
    v_user_id, v_title, v_desc,
    v_main, v_secondaries,
    v_difficulty, v_duration, v_importance,
    'active', v_target_date, (v_plan_mode <> 'own'),
    v_archetype, v_plan_mode, v_period_days
  )
  RETURNING id INTO v_goal_id;

  -- ── 2. Create steps ───────────────────────────────────────────────
  FOR v_step IN
    SELECT value FROM jsonb_array_elements(COALESCE(p_payload->'steps', '[]'::jsonb))
  LOOP
    -- Skip disabled steps
    IF (v_step->>'enabled')::BOOLEAN IS FALSE THEN
      CONTINUE;
    END IF;

    v_type := COALESCE(v_step->>'type', '');

    -- Resolve step category (falls back to goal main_category)
    BEGIN
      v_step_category := COALESCE(NULLIF(v_step->>'main_category', ''), v_main::TEXT)::task_category;
    EXCEPTION WHEN invalid_text_representation THEN
      v_step_category := v_main;
    END;

    IF v_type = 'task' THEN
      INSERT INTO public.tasks (
        user_id, goal_id, title, description,
        main_category, secondary_categories,
        difficulty, duration, importance,
        xp_reward, discipline_xp_reward,
        is_recurring, recurrence, due_date
      ) VALUES (
        v_user_id, v_goal_id,
        COALESCE(NULLIF(v_step->>'title', ''), 'Task'),
        NULLIF(trim(COALESCE(v_step->>'description', '')), ''),
        v_step_category,
        COALESCE(
          (SELECT array_agg(x::task_category)
           FROM jsonb_array_elements_text(v_step->'secondary_categories') AS x),
          '{}'::task_category[]
        ),
        COALESCE((NULLIF(v_step->>'difficulty', ''))::task_difficulty,  'normal'),
        COALESCE((NULLIF(v_step->>'duration',   ''))::task_duration,    'medium'),
        COALESCE((NULLIF(v_step->>'importance', ''))::task_importance,  'normal'),
        COALESCE((v_step->>'xp_reward')::INT,             20),
        COALESCE((v_step->>'discipline_xp_reward')::INT,   0),
        false, NULL,
        CASE WHEN v_step ? 'due_days_from_now'
             THEN (CURRENT_DATE + ((v_step->>'due_days_from_now')::INT * INTERVAL '1 day'))::DATE
             ELSE NULL
        END
      );
      v_inserted_tasks := v_inserted_tasks + 1;

    ELSIF v_type = 'habit' THEN
      INSERT INTO public.habits (
        user_id, goal_id, title, description,
        type, input_type, recurrence, target_value,
        main_category, secondary_categories,
        difficulty, duration, importance,
        xp_reward, discipline_xp_reward
      ) VALUES (
        v_user_id, v_goal_id,
        COALESCE(NULLIF(v_step->>'title', ''), 'Habit'),
        NULLIF(trim(COALESCE(v_step->>'description', '')), ''),
        'good', 'boolean',
        COALESCE((NULLIF(v_step->>'frequency', ''))::recurrence_type, 'daily'),
        1,
        v_step_category,
        COALESCE(
          (SELECT array_agg(x::task_category)
           FROM jsonb_array_elements_text(v_step->'secondary_categories') AS x),
          '{}'::task_category[]
        ),
        COALESCE((NULLIF(v_step->>'difficulty', ''))::task_difficulty, 'easy'),
        COALESCE((NULLIF(v_step->>'duration',   ''))::task_duration,   'short'),
        COALESCE((NULLIF(v_step->>'importance', ''))::task_importance, 'normal'),
        COALESCE((v_step->>'xp_reward')::INT,             15),
        COALESCE((v_step->>'discipline_xp_reward')::INT,   4)
      );
      v_inserted_habits := v_inserted_habits + 1;

    ELSIF v_type = 'milestone' THEN
      INSERT INTO public.milestones (
        goal_id, user_id, title, description,
        xp_reward, target_date
      ) VALUES (
        v_goal_id, v_user_id,
        COALESCE(NULLIF(v_step->>'title', ''), 'Milestone'),
        NULLIF(trim(COALESCE(v_step->>'description', '')), ''),
        COALESCE((v_step->>'xp_reward')::INT, 50),
        CASE WHEN v_step ? 'target_days_from_now'
             THEN (CURRENT_DATE + ((v_step->>'target_days_from_now')::INT * INTERVAL '1 day'))::DATE
             ELSE NULL
        END
      );
      v_inserted_milestones := v_inserted_milestones + 1;

    -- Unknown type → skip silently
    END IF;
  END LOOP;

  RETURN jsonb_build_object(
    'ok',       true,
    'goal_id',  v_goal_id,
    'inserted', jsonb_build_object(
      'tasks',      v_inserted_tasks,
      'habits',     v_inserted_habits,
      'milestones', v_inserted_milestones
    )
  );
END $$;

REVOKE ALL    ON FUNCTION public.create_goal_with_plan(JSONB) FROM public;
GRANT EXECUTE ON FUNCTION public.create_goal_with_plan(JSONB) TO authenticated;

-- ════════════════════════════════════════════════════════════════════
-- END OF MIGRATION
-- ════════════════════════════════════════════════════════════════════
