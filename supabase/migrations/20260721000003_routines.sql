-- ════════════════════════════════════════════════════════════════════
-- Hero — Routines (Phase 21)
--
-- A routine is an ordered bundle of small steps done together at a set time
-- of day ("Morning": meditate → stretch → journal). Distinct from:
--   • task  — one-off with a due date
--   • habit — a single recurring atomic action with a streak
-- The unit of progress is completing the whole block once per day, which
-- awards XP (server-authoritative via apply_xp_gain) and advances a streak.
-- ════════════════════════════════════════════════════════════════════

-- 1) ── routines ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.routines (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title               TEXT NOT NULL,
  scheduled_time      TIME,                                   -- optional reminder time
  reminder_enabled    BOOLEAN NOT NULL DEFAULT false,
  xp_reward           INT NOT NULL DEFAULT 25 CHECK (xp_reward BETWEEN 5 AND 150),
  current_streak      INT NOT NULL DEFAULT 0,
  best_streak         INT NOT NULL DEFAULT 0,
  last_completed_date DATE,
  is_archived         BOOLEAN NOT NULL DEFAULT false,
  sort_order          INT NOT NULL DEFAULT 0,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_routines_user
  ON public.routines (user_id, is_archived);
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_routines_own ON public.routines;
CREATE POLICY p_routines_own ON public.routines
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 2) ── routine_steps ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.routine_steps (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  routine_id       UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title            TEXT NOT NULL,
  duration_minutes INT CHECK (duration_minutes IS NULL OR duration_minutes BETWEEN 1 AND 600),
  sort_order       INT NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_routine_steps_routine
  ON public.routine_steps (routine_id, sort_order);
ALTER TABLE public.routine_steps ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_routine_steps_own ON public.routine_steps;
CREATE POLICY p_routine_steps_own ON public.routine_steps
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 3) ── routine_logs (one completion per routine per day) ────────────
CREATE TABLE IF NOT EXISTS public.routine_logs (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  routine_id   UUID NOT NULL REFERENCES public.routines(id) ON DELETE CASCADE,
  log_date     DATE NOT NULL,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (routine_id, log_date)
);
CREATE INDEX IF NOT EXISTS idx_routine_logs_user_date
  ON public.routine_logs (user_id, log_date);
ALTER TABLE public.routine_logs ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_routine_logs_own ON public.routine_logs;
CREATE POLICY p_routine_logs_own ON public.routine_logs
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 4) ── RPC: complete_routine ────────────────────────────────────────
-- Idempotent per day. Awards xp_reward and advances the streak (consecutive
-- days increment; a gap resets to 1).
CREATE OR REPLACE FUNCTION public.complete_routine(p_routine_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user      UUID := auth.uid();
  v_routine   public.routines%ROWTYPE;
  v_new_streak INT;
  v_xp_result JSONB;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO v_routine
    FROM public.routines
   WHERE id = p_routine_id AND user_id = v_user
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'routine_not_found';
  END IF;

  -- Already completed today → no-op (no double XP).
  IF EXISTS (
    SELECT 1 FROM public.routine_logs
     WHERE routine_id = p_routine_id AND log_date = CURRENT_DATE
  ) THEN
    RETURN jsonb_build_object(
      'ok', true, 'duplicate', true,
      'current_streak', v_routine.current_streak
    );
  END IF;

  INSERT INTO public.routine_logs (user_id, routine_id, log_date)
  VALUES (v_user, p_routine_id, CURRENT_DATE);

  IF v_routine.last_completed_date = CURRENT_DATE - 1 THEN
    v_new_streak := v_routine.current_streak + 1;
  ELSE
    v_new_streak := 1;
  END IF;

  UPDATE public.routines
     SET current_streak      = v_new_streak,
         best_streak         = GREATEST(best_streak, v_new_streak),
         last_completed_date = CURRENT_DATE
   WHERE id = p_routine_id;

  v_xp_result := public.apply_xp_gain(v_user, v_routine.xp_reward);

  RETURN jsonb_build_object(
    'ok', true,
    'duplicate', false,
    'xp_awarded', v_routine.xp_reward,
    'current_streak', v_new_streak,
    'xp_result', v_xp_result
  );
END $$;

REVOKE ALL    ON FUNCTION public.complete_routine(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_routine(UUID) TO authenticated;

-- 5) ── RPC: uncomplete_routine (undo today's completion) ────────────
-- Removes today's log and rolls the streak back by one. XP is intentionally
-- NOT clawed back (matches the app's habit undo — the ledger keeps the gain).
CREATE OR REPLACE FUNCTION public.uncomplete_routine(p_routine_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user    UUID := auth.uid();
  v_deleted INT;
  v_streak  INT;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  DELETE FROM public.routine_logs
   WHERE routine_id = p_routine_id
     AND user_id = v_user
     AND log_date = CURRENT_DATE;
  GET DIAGNOSTICS v_deleted = ROW_COUNT;

  IF v_deleted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'changed', false);
  END IF;

  UPDATE public.routines
     SET current_streak = GREATEST(current_streak - 1, 0),
         last_completed_date = CURRENT_DATE - 1
   WHERE id = p_routine_id AND user_id = v_user
  RETURNING current_streak INTO v_streak;

  RETURN jsonb_build_object('ok', true, 'changed', true, 'current_streak', v_streak);
END $$;

REVOKE ALL    ON FUNCTION public.uncomplete_routine(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.uncomplete_routine(UUID) TO authenticated;
