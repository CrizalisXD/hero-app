-- ════════════════════════════════════════════════════════════════════
-- Фикс: пользовательские челленджи создавались, но были невидимы автору.
--
-- create_user_challenge вставляла запись в challenges, но:
--   1) не заполняла owner_user_id (только created_by) — а RLS-политика
--      p_challenges_view пускает автора именно по owner_user_id, поэтому
--      свежий челлендж прятался от него полностью (даже прямой SELECT = 0);
--   2) не добавляла автора в challenge_participants — а list_my_challenges
--      показывает только те челленджи, где ты участник, поэтому «Мои»
--      оставались пустыми.
--
-- Итог для пользователя: «создал → исчез». В БД при этом копился невидимый
-- мусор. Здесь: заполняем owner_user_id и авто-джойним автора участником.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.create_user_challenge(
  p_title         TEXT,
  p_description   TEXT,
  p_metric_type   TEXT,
  p_target_value  NUMERIC,
  p_end_at        TIMESTAMPTZ,
  p_reward_xp     INT DEFAULT 50
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_id UUID := gen_random_uuid();
  v_title TEXT;
  v_now TIMESTAMPTZ := now();
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  v_title := trim(COALESCE(p_title, ''));
  IF length(v_title) < 2 OR length(v_title) > 100 THEN
    RAISE EXCEPTION 'invalid_title';
  END IF;

  IF p_end_at IS NULL OR p_end_at < v_now + INTERVAL '1 day' THEN
    RAISE EXCEPTION 'invalid_end_at_too_soon';
  END IF;
  IF p_end_at > v_now + INTERVAL '365 days' THEN
    RAISE EXCEPTION 'invalid_end_at_too_far';
  END IF;

  IF p_target_value IS NULL OR p_target_value <= 0 THEN
    RAISE EXCEPTION 'invalid_target_value';
  END IF;

  IF p_metric_type NOT IN
     ('streak','count','distance','xp','habit','category','activity_day') THEN
    RAISE EXCEPTION 'invalid_metric_type';
  END IF;

  INSERT INTO public.challenges (
    id, challenge_type, metric_type,
    title_custom, description_custom,
    start_at, end_at, target_value, reward_xp,
    is_public, is_active, owner_user_id, created_by
  )
  VALUES (
    v_id, 'user', p_metric_type,
    v_title,
    NULLIF(trim(COALESCE(p_description, '')), ''),
    v_now, p_end_at, p_target_value,
    LEAST(GREATEST(COALESCE(p_reward_xp, 50), 0), 500),
    false, true, v_user, v_user
  );

  -- Автор сразу участник: иначе list_my_challenges (фильтр по участию) его
  -- челлендж не покажет. UNIQUE(challenge_id,user_id) защищает от дублей.
  INSERT INTO public.challenge_participants (challenge_id, user_id)
  VALUES (v_id, v_user)
  ON CONFLICT (challenge_id, user_id) DO NOTHING;

  RETURN jsonb_build_object(
    'ok', true,
    'challenge_id', v_id
  );
END $$;

REVOKE ALL   ON FUNCTION public.create_user_challenge(TEXT, TEXT, TEXT, NUMERIC, TIMESTAMPTZ, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.create_user_challenge(TEXT, TEXT, TEXT, NUMERIC, TIMESTAMPTZ, INT) TO authenticated;

-- ── Бэкфил ранее созданных невидимых челленджей ────────────────────
-- Попытки, сделанные до фикса, лежат в БД с owner_user_id = NULL и без
-- участника — воскрешаем их, чтобы авторы наконец увидели своё.
UPDATE public.challenges
   SET owner_user_id = created_by
 WHERE challenge_type = 'user'
   AND owner_user_id IS NULL
   AND created_by IS NOT NULL;

INSERT INTO public.challenge_participants (challenge_id, user_id)
SELECT c.id, c.created_by
  FROM public.challenges c
 WHERE c.challenge_type = 'user'
   AND c.created_by IS NOT NULL
ON CONFLICT (challenge_id, user_id) DO NOTHING;
