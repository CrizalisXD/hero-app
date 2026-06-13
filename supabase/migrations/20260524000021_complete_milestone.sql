-- ════════════════════════════════════════════════════════════════════
-- Hero — 0024_complete_milestone.sql
--
-- Phase 7 created milestones inside create_goal_with_plan but never
-- added an RPC to mark one as done. The goal detail screen needs that
-- so the user can actually tick off the AI-suggested checkpoints.
--
-- Behaviour mirrors complete_task: idempotent, awards XP via the
-- ledger (so double-tap doesn't double-pay), updates is_done +
-- completed_at, hooks energy reward and achievements.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.complete_milestone(p_milestone_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_milestone public.milestones%ROWTYPE;
  v_xp INT;
  v_xp_result JSONB;
  v_inserted INT;
  v_pre_ids TEXT[];
  v_unlocked JSONB;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  SELECT COALESCE(array_agg(achievement_id), '{}'::TEXT[])
    INTO v_pre_ids
    FROM public.user_achievements
   WHERE user_id = v_user;

  SELECT * INTO v_milestone FROM public.milestones
   WHERE id = p_milestone_id AND user_id = v_user
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'milestone_not_found'; END IF;

  IF v_milestone.is_done THEN
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'milestone_id', p_milestone_id);
  END IF;

  v_xp := COALESCE(v_milestone.xp_reward, 50);

  INSERT INTO public.xp_ledger
    (user_id, source_type, source_id, category, xp_amount, discipline_xp_amount, log_date)
  VALUES
    (v_user, 'milestone', p_milestone_id, NULL, v_xp, 0, CURRENT_DATE)
  ON CONFLICT DO NOTHING;

  GET DIAGNOSTICS v_inserted = ROW_COUNT;
  IF v_inserted = 0 THEN
    UPDATE public.milestones
       SET is_done = true, completed_at = now()
     WHERE id = p_milestone_id;
    RETURN jsonb_build_object('ok', true, 'duplicate', true, 'milestone_id', p_milestone_id);
  END IF;

  UPDATE public.milestones
     SET is_done = true, completed_at = now()
   WHERE id = p_milestone_id;

  v_xp_result := public.apply_xp_gain(v_user, v_xp);

  -- Energy reward — bigger than task because a milestone marks real
  -- progress.
  PERFORM public.reward_energy(v_user, 10);

  PERFORM public.check_and_unlock_achievements(
    v_user,
    'milestone_completed',
    jsonb_build_object('milestone_id', p_milestone_id, 'goal_id', v_milestone.goal_id)
  );

  SELECT COALESCE(jsonb_agg(jsonb_build_object(
           'id',              a.id,
           'title_key',       a.title_key,
           'description_key', a.description_key,
           'icon_key',        a.icon_key,
           'rarity',          a.rarity,
           'reward_xp',       a.reward_xp,
           'reward_coins',    a.reward_coins
         ) ORDER BY ua.unlocked_at), '[]'::jsonb)
    INTO v_unlocked
    FROM public.user_achievements ua
    JOIN public.achievements a ON a.id = ua.achievement_id
   WHERE ua.user_id = v_user
     AND NOT (ua.achievement_id = ANY (v_pre_ids));

  RETURN jsonb_build_object(
    'ok', true,
    'duplicate', false,
    'milestone_id', p_milestone_id,
    'xp_gained', v_xp,
    'character', v_xp_result,
    'unlocked_achievements', v_unlocked
  );
END $$;

REVOKE ALL   ON FUNCTION public.complete_milestone(UUID) FROM public;
GRANT EXECUTE ON FUNCTION public.complete_milestone(UUID) TO authenticated;
