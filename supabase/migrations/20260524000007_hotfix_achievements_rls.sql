-- ════════════════════════════════════════════════════════════════════
-- Hero — 0009_hotfix_achievements_rls.sql
--
-- Phase 12's migration GRANT'ed SELECT on public.achievements to
-- authenticated but forgot to ENABLE ROW LEVEL SECURITY. Supabase
-- Security Advisor flags this as CRITICAL because the table is
-- exposed via PostgREST and would otherwise be reachable by any
-- caller with a valid anon key — including ones we didn't grant.
--
-- Fix: enable RLS and add a SELECT policy that mirrors the existing
-- grant. The catalog is read-only from the app — no INSERT/UPDATE/
-- DELETE policy needed (modifications go through migrations).
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_achievements_read ON public.achievements;
CREATE POLICY p_achievements_read ON public.achievements
  FOR SELECT
  TO authenticated
  USING (true);
