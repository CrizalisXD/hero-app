-- ════════════════════════════════════════════════════════════════════
-- Hero — 0013_hotfix_gen_random_bytes.sql
--
-- Phase 13 (social_lite) introduced `generate_unique_username()` which
-- calls `gen_random_bytes(N)`. On Supabase cloud, pgcrypto is installed
-- in the `extensions` schema, NOT public. `ensure_user_bootstrap` has
-- `SET search_path = public` (security hardening) → callers of
-- `generate_unique_username` (which inherits that search_path) hit:
--
--   function gen_random_bytes(integer) does not exist
--
-- Symptom in app: splash screen shows endless spinner because
-- ensure_user_bootstrap RPC throws on first authenticated launch.
--
-- Fix: schema-qualify the calls inside generate_unique_username so it
-- works regardless of search_path. No behavior change otherwise.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.generate_unique_username()
RETURNS TEXT LANGUAGE plpgsql AS $$
DECLARE
  v_candidate TEXT;
  v_attempts  INT := 0;
BEGIN
  LOOP
    v_candidate := 'hero_' || substr(encode(extensions.gen_random_bytes(4), 'hex'), 1, 8);
    EXIT WHEN NOT EXISTS (
      SELECT 1 FROM public.user_public_profiles WHERE username = v_candidate
    );
    v_attempts := v_attempts + 1;
    IF v_attempts > 10 THEN
      v_candidate := 'hero_' || substr(encode(extensions.gen_random_bytes(8), 'hex'), 1, 16);
      EXIT;
    END IF;
  END LOOP;
  RETURN v_candidate;
END $$;
