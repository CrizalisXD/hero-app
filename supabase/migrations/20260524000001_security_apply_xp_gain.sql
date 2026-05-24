-- ════════════════════════════════════════════════════════════════════
-- Hero — 20260524000001_security_apply_xp_gain.sql
--
-- Phase 1 security fix:
--   apply_xp_gain(UUID, INT) is an internal helper — it must NOT be
--   callable directly by authenticated users via the PostgREST API.
--   Without an explicit REVOKE, PostgreSQL's default PUBLIC execute
--   privilege lets any authenticated user award themselves arbitrary XP.
--
--   complete_task and complete_habit_checkin call apply_xp_gain
--   internally as the DB owner (SECURITY DEFINER context) — they do
--   not need an EXECUTE grant; internal SQL calls bypass function ACLs
--   when both caller and callee share the same DB owner role.
--
-- Apply: supabase db push  OR  Supabase → SQL Editor.
-- ════════════════════════════════════════════════════════════════════

REVOKE ALL ON FUNCTION public.apply_xp_gain(UUID, INT) FROM public;
REVOKE ALL ON FUNCTION public.apply_xp_gain(UUID, INT) FROM anon;
REVOKE ALL ON FUNCTION public.apply_xp_gain(UUID, INT) FROM authenticated;
