-- ════════════════════════════════════════════════════════════════════
-- Hero — 0005_account_lifecycle.sql  (Phase 11)
--
-- Adds:
--   - profiles.deletion_requested_at / scheduled_deletion_at columns
--   - RPC request_account_deletion(reason)   — schedules +30 days
--   - RPC cancel_account_deletion()          — called on next sign-in
--   - RPC export_my_data()                   — returns full JSON dump
--   - RPC clear_ai_memory()                  — deletes ai_memory rows
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS deletion_requested_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS scheduled_deletion_at TIMESTAMPTZ;

-- ── RPC: request deletion ─────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.request_account_deletion(p_reason TEXT DEFAULT NULL)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id  UUID := auth.uid();
  v_scheduled TIMESTAMPTZ := now() + INTERVAL '30 days';
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.profiles
     SET deletion_requested_at = now(),
         scheduled_deletion_at = v_scheduled,
         updated_at            = now()
   WHERE id = v_user_id;

  -- p_reason is intentionally not stored yet — add a separate table later.
  RETURN jsonb_build_object(
    'ok',                    true,
    'scheduled_deletion_at', v_scheduled
  );
END $$;
REVOKE ALL ON FUNCTION public.request_account_deletion(TEXT) FROM public;
GRANT EXECUTE ON FUNCTION public.request_account_deletion(TEXT) TO authenticated;

-- ── RPC: cancel deletion (called by client on next sign-in) ───────
CREATE OR REPLACE FUNCTION public.cancel_account_deletion()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id       UUID := auth.uid();
  v_was_scheduled BOOLEAN;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT scheduled_deletion_at IS NOT NULL INTO v_was_scheduled
    FROM public.profiles WHERE id = v_user_id;

  UPDATE public.profiles
     SET deletion_requested_at = NULL,
         scheduled_deletion_at = NULL,
         updated_at            = now()
   WHERE id = v_user_id;

  RETURN jsonb_build_object('ok', true, 'was_scheduled', COALESCE(v_was_scheduled, false));
END $$;
REVOKE ALL ON FUNCTION public.cancel_account_deletion() FROM public;
GRANT EXECUTE ON FUNCTION public.cancel_account_deletion() TO authenticated;

-- ── RPC: export full data dump ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.export_my_data()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_result  JSONB;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT jsonb_build_object(
    'export_version',        1,
    'exported_at',           now(),
    'user_id',               v_user_id,
    'profile',
      (SELECT row_to_json(p) FROM public.profiles p WHERE id = v_user_id),
    'user',
      (SELECT row_to_json(u) FROM public.users u WHERE id = v_user_id),
    'character_stats',
      (SELECT row_to_json(c) FROM public.character_stats c WHERE user_id = v_user_id),
    'meta_stats',
      (SELECT row_to_json(m) FROM public.meta_stats m WHERE user_id = v_user_id),
    'category_progress',
      (SELECT jsonb_agg(row_to_json(cp)) FROM public.category_progress cp WHERE user_id = v_user_id),
    'tasks',
      (SELECT jsonb_agg(row_to_json(t)) FROM public.tasks t WHERE user_id = v_user_id),
    'habits',
      (SELECT jsonb_agg(row_to_json(h)) FROM public.habits h WHERE user_id = v_user_id),
    'goals',
      (SELECT jsonb_agg(row_to_json(g)) FROM public.goals g WHERE user_id = v_user_id),
    'milestones',
      (SELECT jsonb_agg(row_to_json(mi)) FROM public.milestones mi WHERE user_id = v_user_id),
    'xp_ledger',
      (SELECT jsonb_agg(row_to_json(x)) FROM public.xp_ledger x WHERE user_id = v_user_id),
    'ai_conversations',
      (SELECT jsonb_agg(row_to_json(c)) FROM public.ai_conversations c WHERE user_id = v_user_id),
    'ai_messages',
      (SELECT jsonb_agg(
        jsonb_build_object('role', role, 'content', content, 'created_at', created_at)
      ) FROM public.ai_messages WHERE user_id = v_user_id),
    'user_profile_snapshots',
      (SELECT jsonb_agg(row_to_json(s)) FROM public.user_profile_snapshots s WHERE user_id = v_user_id),
    'user_consents',
      (SELECT jsonb_agg(row_to_json(uc)) FROM public.user_consents uc WHERE user_id = v_user_id),
    'notification_settings',
      (SELECT row_to_json(ns) FROM public.notification_settings ns WHERE user_id = v_user_id)
  ) INTO v_result;

  RETURN v_result;
END $$;
REVOKE ALL ON FUNCTION public.export_my_data() FROM public;
GRANT EXECUTE ON FUNCTION public.export_my_data() TO authenticated;

-- ── RPC: clear AI memory ──────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.clear_ai_memory()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID := auth.uid();
  v_deleted INT;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  DELETE FROM public.ai_memory WHERE user_id = v_user_id;
  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN jsonb_build_object('ok', true, 'deleted', v_deleted);
END $$;
REVOKE ALL ON FUNCTION public.clear_ai_memory() FROM public;
GRANT EXECUTE ON FUNCTION public.clear_ai_memory() TO authenticated;
