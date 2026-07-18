-- ════════════════════════════════════════════════════════════════════
-- Фикс: вкладка «Мои» падала после того, как пользовательские челленджи
-- стали видимыми.
--
-- list_my_challenges отдавала только title_key/description_key (ключи
-- локализации системных челленджей). У пользовательских челленджей эти
-- поля NULL — заголовок лежит в title_custom/description_custom. Клиент
-- (ChallengeParticipant.titleKey — non-null) падал на NULL → весь список
-- «Мои» уходил в ошибку «Что-то пошло не так».
--
-- Добавляем title_custom/description_custom в выдачу. Клиент выбирает
-- custom, если он есть, иначе резолвит ключ.
-- ════════════════════════════════════════════════════════════════════

-- CREATE OR REPLACE не умеет менять RETURNS TABLE (добавляем колонки) —
-- Postgres требует пересоздать функцию.
DROP FUNCTION IF EXISTS public.list_my_challenges();

CREATE FUNCTION public.list_my_challenges()
RETURNS TABLE (
  participant_id     UUID,
  challenge_id       UUID,
  metric_type        TEXT,
  title_key          TEXT,
  description_key    TEXT,
  title_custom       TEXT,
  description_custom TEXT,
  target_value       NUMERIC,
  progress_value     NUMERIC,
  status             TEXT,
  reward_xp          INT,
  end_at             TIMESTAMPTZ,
  joined_at          TIMESTAMPTZ,
  completed_at       TIMESTAMPTZ
)
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  RETURN QUERY
    -- title_key через COALESCE: старый клиент (в уже установленных сборках)
    -- читает только title_key и падал на NULL. Отдавая ему custom-текст под
    -- видом ключа, спасаем вкладку «Мои» без пересборки приложения — его
    -- switch-резолвер просто вернёт текст как есть. Новый клиент берёт
    -- отдельный title_custom и не зависит от этого.
    SELECT cp.id, c.id, c.metric_type,
           COALESCE(c.title_key, c.title_custom)             AS title_key,
           COALESCE(c.description_key, c.description_custom)  AS description_key,
           c.title_custom, c.description_custom,
           c.target_value, cp.progress_value, cp.status, c.reward_xp,
           c.end_at, cp.joined_at, cp.completed_at
      FROM public.challenge_participants cp
      JOIN public.challenges c ON c.id = cp.challenge_id
     WHERE cp.user_id = v_me
     ORDER BY cp.joined_at DESC;
END $$;
GRANT EXECUTE ON FUNCTION public.list_my_challenges() TO authenticated;
