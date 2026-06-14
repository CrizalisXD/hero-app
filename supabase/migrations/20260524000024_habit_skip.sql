-- ════════════════════════════════════════════════════════════════════
-- Hero — 0027_habit_skip.sql
--
-- "Skip today" support for habits. User feedback: when life gets in the
-- way (sick day, travel, anything intentional) the user wants to mark
-- today as "consciously skipped" instead of breaking their streak by
-- not logging anything.
--
-- Design:
--   • habit_logs.is_skip BOOLEAN DEFAULT false — distinguishes a
--     skipped day from a real check-in. Same UNIQUE(habit_id, log_date)
--     keeps the user from double-acting on a single day.
--   • skip_habit_today(habit_id) RPC: inserts a skip row, awards no
--     XP, leaves the streak intact. Tomorrow's check-in still sees a
--     habit_logs row for yesterday → streak math continues normally,
--     so the chain of "active days" is unbroken.
--   • uncomplete_habit_checkin updated to handle skip rows too:
--     deleting a skip row simply removes today's entry without any
--     XP / streak adjustments (nothing was awarded to roll back).
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.habit_logs
  ADD COLUMN IF NOT EXISTS is_skip BOOLEAN NOT NULL DEFAULT false;


CREATE OR REPLACE FUNCTION public.skip_habit_today(p_habit_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_habit public.habits%ROWTYPE;
  v_today DATE := CURRENT_DATE;
  v_inserted INT;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT * INTO v_habit FROM public.habits
   WHERE id = p_habit_id AND user_id = v_user
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'habit_not_found'; END IF;

  -- Idempotent: if today's row already exists (real check-in or
  -- previous skip) we don't double up.
  INSERT INTO public.habit_logs
    (habit_id, user_id, log_date, value, xp_earned, is_skip)
  VALUES (p_habit_id, v_user, v_today, 0, 0, true)
  ON CONFLICT (habit_id, log_date) DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'habit_id', p_habit_id);
  END IF;

  -- No streak change, no XP, no category_progress / meta_stats touch —
  -- this is intentionally a quiet operation.

  RETURN jsonb_build_object(
    'ok', true,
    'duplicate', false,
    'habit_id', p_habit_id,
    'skip', true
  );
END $$;

REVOKE ALL   ON FUNCTION public.skip_habit_today(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.skip_habit_today(UUID) TO authenticated;
