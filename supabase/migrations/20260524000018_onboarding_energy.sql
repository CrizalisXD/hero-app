-- ════════════════════════════════════════════════════════════════════
-- Hero — 0021_onboarding_energy.sql
--
-- Wires the onboarding diagnostic into the starting state of the
-- energy mechanic. After the user finishes the questionnaire, their
-- self-reported energy level should shape how much they actually
-- *start with* — but not their cap.
--
-- Design decision (locked in with the user during Phase 18):
--   energy_max stays at 100 for everyone at start. Tired users
--   shouldn't be permanently penalised — they should ramp up by
--   actually using the app (passive regen + daily bonus + Endurance
--   level-ups). The cap only grows above 100 once they invest in the
--   Endurance category over time.
--
--   Only the *starting* energy value varies, so a fresh "I'm
--   exhausted, just signed up" user sees 30/100 and is gently nudged
--   to pick one tiny thing, while a "full of energy" user sees 100/100
--   and can plan a busier first day.
--
-- Mapping by users.current_energy_level (1-5 from onboarding):
--   1 → 30   "Маленький старт. Одна привычка хватит."
--   2 → 55   "Аккуратно. Одна цель максимум."
--   3 → 80   default — average new user
--   4 → 95   "Готов погружаться"
--   5 → 100  full bar
--
-- Called once from the client at the end of the onboarding flow
-- (after onboarding-bootstrap Edge Function returns). Idempotent —
-- safe to call again, but only kicks in when the user hasn't yet
-- spent any energy (energy = energy_max), so a repeat call doesn't
-- overwrite a half-drained bar mid-day.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.apply_onboarding_to_stats()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_energy_level INT;
  v_starting_energy INT;
  v_current_energy INT;
  v_current_max INT;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT current_energy_level INTO v_energy_level
    FROM public.users WHERE id = v_user;

  -- Fall back to mid-range if onboarding skipped — keeps the call safe.
  v_energy_level := COALESCE(v_energy_level, 3);
  IF v_energy_level < 1 THEN v_energy_level := 1; END IF;
  IF v_energy_level > 5 THEN v_energy_level := 5; END IF;

  v_starting_energy := CASE v_energy_level
    WHEN 1 THEN 30
    WHEN 2 THEN 55
    WHEN 3 THEN 80
    WHEN 4 THEN 95
    WHEN 5 THEN 100
  END;

  -- Idempotency guard: only apply when the user looks "fresh" — i.e.
  -- energy is still at max from ensure_user_bootstrap. Otherwise the
  -- user is already mid-flow and a repeat call would reset their day.
  SELECT energy, energy_max INTO v_current_energy, v_current_max
    FROM public.character_stats WHERE user_id = v_user;

  IF v_current_energy IS NULL THEN
    RETURN jsonb_build_object(
      'ok', false,
      'reason', 'no_character_stats'
    );
  END IF;

  IF v_current_energy < v_current_max THEN
    -- User has already started spending — don't touch.
    RETURN jsonb_build_object(
      'ok', true,
      'applied', false,
      'reason', 'user_already_active',
      'energy', v_current_energy,
      'max', v_current_max
    );
  END IF;

  UPDATE public.character_stats
     SET energy = v_starting_energy,
         energy_last_regen_at = now(),
         updated_at = now()
   WHERE user_id = v_user;

  RETURN jsonb_build_object(
    'ok', true,
    'applied', true,
    'energy_level', v_energy_level,
    'energy', v_starting_energy,
    'max', v_current_max
  );
END $$;

REVOKE ALL   ON FUNCTION public.apply_onboarding_to_stats() FROM public;
GRANT EXECUTE ON FUNCTION public.apply_onboarding_to_stats() TO authenticated;
