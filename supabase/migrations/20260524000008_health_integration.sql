-- ════════════════════════════════════════════════════════════════════
-- Hero — 0010_health_integration.sql  (Phase 15)
--
-- Adds:
--   - health_daily_summaries — per-day aggregates per source
--                              (apple_health / health_connect / manual)
--   - user_integrations      — registry of connected providers + last_sync
--   - RPC upsert_health_summary(date, steps, distance, workouts, source):
--       UPSERT day row, compute delta_distance vs previous value, and
--       PERFORM process_challenge_progress so monthly_run gets credit.
--   - RPC get_today_health()    — aggregate of today's row(s)
--   - RPC disconnect_integration(provider)
-- ════════════════════════════════════════════════════════════════════

-- 1) ── health_daily_summaries ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.health_daily_summaries (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  date               DATE NOT NULL,
  steps              INT,
  distance_meters    NUMERIC,
  active_energy_kcal NUMERIC,
  workouts_count     INT NOT NULL DEFAULT 0,
  sleep_minutes      INT,
  source             TEXT NOT NULL CHECK (source IN ('apple_health','health_connect','manual')),
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, date, source)
);
CREATE INDEX IF NOT EXISTS idx_health_user_date
  ON public.health_daily_summaries (user_id, date DESC);
DROP TRIGGER IF EXISTS tg_health_updated_at ON public.health_daily_summaries;
CREATE TRIGGER tg_health_updated_at
  BEFORE UPDATE ON public.health_daily_summaries
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();
ALTER TABLE public.health_daily_summaries ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_health_own ON public.health_daily_summaries;
CREATE POLICY p_health_own ON public.health_daily_summaries
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 2) ── user_integrations ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_integrations (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  provider         TEXT NOT NULL,
  status           TEXT NOT NULL CHECK (status IN ('connected','disconnected','revoked','error')) DEFAULT 'connected',
  scopes           TEXT[] NOT NULL DEFAULT '{}',
  external_user_id TEXT,
  last_sync_at     TIMESTAMPTZ,
  sync_settings    JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, provider)
);
DROP TRIGGER IF EXISTS tg_user_integrations_updated_at ON public.user_integrations;
CREATE TRIGGER tg_user_integrations_updated_at
  BEFORE UPDATE ON public.user_integrations
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();
ALTER TABLE public.user_integrations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS p_int_own ON public.user_integrations;
CREATE POLICY p_int_own ON public.user_integrations
  FOR ALL USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- 3) ── RPC: upsert_health_summary ─────────────────────────────────
-- Called by HealthSyncService once per day-row. Delta vs previously
-- known value of distance_meters is forwarded to
-- process_challenge_progress so monthly_run accumulates.
-- Returns delta_distance for client debugging.
CREATE OR REPLACE FUNCTION public.upsert_health_summary(
  p_date            DATE,
  p_steps           INT,
  p_distance_meters NUMERIC,
  p_workouts_count  INT,
  p_source          TEXT
)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_user_id     UUID    := auth.uid();
  v_old_distance NUMERIC := 0;
  v_delta       NUMERIC := 0;
BEGIN
  IF v_user_id IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF p_source NOT IN ('apple_health','health_connect','manual') THEN
    RAISE EXCEPTION 'invalid_source';
  END IF;

  SELECT COALESCE(distance_meters, 0) INTO v_old_distance
    FROM public.health_daily_summaries
   WHERE user_id = v_user_id AND date = p_date AND source = p_source;

  INSERT INTO public.health_daily_summaries
    (user_id, date, steps, distance_meters, workouts_count, source)
  VALUES
    (v_user_id, p_date, p_steps, p_distance_meters, p_workouts_count, p_source)
  ON CONFLICT (user_id, date, source) DO UPDATE
    SET steps           = EXCLUDED.steps,
        distance_meters = EXCLUDED.distance_meters,
        workouts_count  = EXCLUDED.workouts_count,
        updated_at      = now();

  -- Delta strictly non-negative — never decrement challenge progress
  -- if a corrupt re-sync briefly reports less.
  v_delta := GREATEST(0, COALESCE(p_distance_meters, 0) - v_old_distance);

  IF v_delta > 0 THEN
    PERFORM public.process_challenge_progress(
      v_user_id, 'health_distance', v_delta,
      NULL, p_source, NULL
    );
  END IF;

  -- last_sync_at touch.
  INSERT INTO public.user_integrations (user_id, provider, status, last_sync_at)
  VALUES (v_user_id, p_source, 'connected', now())
  ON CONFLICT (user_id, provider) DO UPDATE
    SET status       = 'connected',
        last_sync_at = now(),
        updated_at   = now();

  RETURN jsonb_build_object('ok', true, 'delta_distance', v_delta);
END $$;
REVOKE ALL ON FUNCTION public.upsert_health_summary(DATE, INT, NUMERIC, INT, TEXT) FROM public;
GRANT EXECUTE ON FUNCTION public.upsert_health_summary(DATE, INT, NUMERIC, INT, TEXT) TO authenticated;

-- 4) ── RPC: get_today_health ──────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_today_health()
RETURNS TABLE (
  steps           INT,
  distance_meters NUMERIC,
  workouts_count  INT,
  last_sync_at    TIMESTAMPTZ
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    WITH today AS (
      SELECT COALESCE(SUM(s.steps), 0)::INT          AS steps,
             COALESCE(SUM(s.distance_meters), 0)     AS distance_meters,
             COALESCE(SUM(s.workouts_count), 0)::INT AS workouts_count
        FROM public.health_daily_summaries s
       WHERE s.user_id = v_me AND s.date = CURRENT_DATE
    )
    SELECT today.steps,
           today.distance_meters,
           today.workouts_count,
           (SELECT MAX(last_sync_at) FROM public.user_integrations
             WHERE user_id = v_me
               AND provider IN ('apple_health','health_connect'))
      FROM today;
END $$;
GRANT EXECUTE ON FUNCTION public.get_today_health() TO authenticated;

-- 5) ── RPC: disconnect_integration ────────────────────────────────
CREATE OR REPLACE FUNCTION public.disconnect_integration(p_provider TEXT)
RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  UPDATE public.user_integrations
     SET status     = 'disconnected',
         updated_at = now()
   WHERE user_id   = auth.uid()
     AND provider  = p_provider;
  RETURN jsonb_build_object('ok', true);
END $$;
GRANT EXECUTE ON FUNCTION public.disconnect_integration(TEXT) TO authenticated;
