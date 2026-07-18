-- ════════════════════════════════════════════════════════════════════
-- Hero — «Хочу попробовать» v2: мечта ≠ цель.
--
-- Мечта («прыгнуть с парашютом») — это НЕ цель, которую тащат и
-- декомпозируют. Она просто живёт, пока человек не надумает. Надумал —
-- уходит в goals (converted_goal_id) или в челлендж.
--
-- Ключевое решение: мечта — ОДНА каноническая запись на всех (dreams),
-- а «хочу» человека — подписка на неё (dream_follows). Если бы у каждого
-- была своя копия, оценки и обсуждение размазались бы по копиям: у всех
-- по нулю звёзд и пустому чату, социалка не заводится.
--
-- Три РАЗНЫХ числа — сознательно не смешаны в одну «звёздность»:
--   want_count  — сколько людей тоже хотят. Солидарность, а не оценка:
--                 поставить «3 из 5» чужой мечте («помириться с отцом»)
--                 некому и незачем.
--   difficulty  — сложность реализации, голосование сообщества. Толпа
--                 знает лучше автора и исправляет страх.
--   worth       — «стоило того». ТОЛЬКО от тех, кто сделал; см.
--                 ck_worth_requires_done. Оценивают опыт, не мечту.
--
-- Приватность: в dreams не пишут ничего личного — она общая. Личное
-- (заметка, фото, факт «я хочу») живёт в dream_follows и по умолчанию
-- приватно (is_public = false).
-- ════════════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 1) ── dreams: канонический справочник ─────────────────────────────
CREATE TABLE IF NOT EXISTS public.dreams (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title            TEXT NOT NULL CHECK (btrim(title) <> ''),
  -- Ключ дедупликации. Точное схлопывание регистра/пробелов; похожие
  -- формулировки ловит поиск по триграммам (idx_dreams_title_trgm),
  -- который клиент показывает как «вы имели в виду ...?».
  title_norm       TEXT GENERATED ALWAYS AS (lower(btrim(title))) STORED,
  category         task_category,
  created_by       UUID REFERENCES public.users(id) ON DELETE SET NULL,
  -- Модерация: справочник общий, поэтому мусор прячем от всех сразу.
  is_approved      BOOLEAN NOT NULL DEFAULT true,
  is_deleted       BOOLEAN NOT NULL DEFAULT false,
  -- Счётчики денормализованы: их пересчитывают триггеры ниже. Читать
  -- агрегаты на каждый показ витрины слишком дорого.
  want_count       INT NOT NULL DEFAULT 0,
  done_count       INT NOT NULL DEFAULT 0,
  difficulty_sum   INT NOT NULL DEFAULT 0,
  difficulty_votes INT NOT NULL DEFAULT 0,
  worth_sum        INT NOT NULL DEFAULT 0,
  worth_votes      INT NOT NULL DEFAULT 0,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dreams_title_norm
  ON public.dreams (title_norm) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_dreams_title_trgm
  ON public.dreams USING gin (title_norm gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_dreams_popular
  ON public.dreams (want_count DESC)
  WHERE is_deleted = false AND is_approved = true;

DROP TRIGGER IF EXISTS tg_dreams_updated_at ON public.dreams;
CREATE TRIGGER tg_dreams_updated_at
  BEFORE UPDATE ON public.dreams
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 2) ── dream_follows: «хочу» конкретного человека ──────────────────
CREATE TABLE IF NOT EXISTS public.dream_follows (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dream_id          UUID NOT NULL REFERENCES public.dreams(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  -- Опт-ин: попасть в «кто хочет / кто сделал» можно только явно.
  is_public         BOOLEAN NOT NULL DEFAULT false,
  done_at           TIMESTAMPTZ,
  worth_rating      INT CHECK (worth_rating BETWEEN 1 AND 5),
  note              TEXT,
  photo_url         TEXT,
  converted_goal_id UUID REFERENCES public.goals(id) ON DELETE SET NULL,
  converted_task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
  is_deleted        BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (dream_id, user_id),
  -- Право на «стоило того» даёт только факт, что сделал. Это и есть то,
  -- что отличает его от накручиваемых want/difficulty.
  CONSTRAINT ck_worth_requires_done
    CHECK (worth_rating IS NULL OR done_at IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_dream_follows_user
  ON public.dream_follows (user_id, created_at DESC) WHERE is_deleted = false;
CREATE INDEX IF NOT EXISTS idx_dream_follows_done_public
  ON public.dream_follows (dream_id, done_at DESC)
  WHERE is_deleted = false AND is_public = true AND done_at IS NOT NULL;

DROP TRIGGER IF EXISTS tg_dream_follows_updated_at ON public.dream_follows;
CREATE TRIGGER tg_dream_follows_updated_at
  BEFORE UPDATE ON public.dream_follows
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 3) ── dream_difficulty_votes: сложность голосованием ──────────────
CREATE TABLE IF NOT EXISTS public.dream_difficulty_votes (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dream_id   UUID NOT NULL REFERENCES public.dreams(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  value      INT NOT NULL CHECK (value BETWEEN 1 AND 5),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (dream_id, user_id)
);

DROP TRIGGER IF EXISTS tg_dream_difficulty_updated_at ON public.dream_difficulty_votes;
CREATE TRIGGER tg_dream_difficulty_updated_at
  BEFORE UPDATE ON public.dream_difficulty_votes
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 4) ── dream_comments: обсуждение у канонической мечты ─────────────
CREATE TABLE IF NOT EXISTS public.dream_comments (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  dream_id   UUID NOT NULL REFERENCES public.dreams(id) ON DELETE CASCADE,
  user_id    UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  body       TEXT NOT NULL CHECK (btrim(body) <> '' AND length(body) <= 2000),
  is_deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_dream_comments_dream
  ON public.dream_comments (dream_id, created_at DESC) WHERE is_deleted = false;

DROP TRIGGER IF EXISTS tg_dream_comments_updated_at ON public.dream_comments;
CREATE TRIGGER tg_dream_comments_updated_at
  BEFORE UPDATE ON public.dream_comments
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 5) ── dream_reports: жалобы ───────────────────────────────────────
-- Публичный контент без кнопки «пожаловаться» не запускается: первый же
-- тролль портит общий справочник для всех.
CREATE TABLE IF NOT EXISTS public.dream_reports (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type TEXT NOT NULL CHECK (target_type IN ('dream','comment')),
  target_id   UUID NOT NULL,
  user_id     UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reason      TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (target_type, target_id, user_id)
);

-- 6) ── Пересчёт счётчиков ──────────────────────────────────────────
-- Считаем заново по dream_id, а не инкрементами: инкременты врут на
-- soft-delete и смене worth_rating, а пересчёт по одной мечте дёшев.
CREATE OR REPLACE FUNCTION public.tg_dreams_recount_follows()
RETURNS TRIGGER AS $$
DECLARE v_dream UUID;
BEGIN
  v_dream := COALESCE(NEW.dream_id, OLD.dream_id);
  UPDATE public.dreams d SET
    want_count = (
      SELECT count(*) FROM public.dream_follows f
      WHERE f.dream_id = v_dream AND f.is_deleted = false),
    done_count = (
      SELECT count(*) FROM public.dream_follows f
      WHERE f.dream_id = v_dream AND f.is_deleted = false
        AND f.done_at IS NOT NULL),
    worth_sum = (
      SELECT COALESCE(sum(f.worth_rating), 0) FROM public.dream_follows f
      WHERE f.dream_id = v_dream AND f.is_deleted = false
        AND f.worth_rating IS NOT NULL),
    worth_votes = (
      SELECT count(*) FROM public.dream_follows f
      WHERE f.dream_id = v_dream AND f.is_deleted = false
        AND f.worth_rating IS NOT NULL)
  WHERE d.id = v_dream;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS tg_dream_follows_recount ON public.dream_follows;
CREATE TRIGGER tg_dream_follows_recount
  AFTER INSERT OR UPDATE OR DELETE ON public.dream_follows
  FOR EACH ROW EXECUTE FUNCTION public.tg_dreams_recount_follows();

CREATE OR REPLACE FUNCTION public.tg_dreams_recount_difficulty()
RETURNS TRIGGER AS $$
DECLARE v_dream UUID;
BEGIN
  v_dream := COALESCE(NEW.dream_id, OLD.dream_id);
  UPDATE public.dreams d SET
    difficulty_sum = (
      SELECT COALESCE(sum(v.value), 0) FROM public.dream_difficulty_votes v
      WHERE v.dream_id = v_dream),
    difficulty_votes = (
      SELECT count(*) FROM public.dream_difficulty_votes v
      WHERE v.dream_id = v_dream)
  WHERE d.id = v_dream;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS tg_dream_difficulty_recount ON public.dream_difficulty_votes;
CREATE TRIGGER tg_dream_difficulty_recount
  AFTER INSERT OR UPDATE OR DELETE ON public.dream_difficulty_votes
  FOR EACH ROW EXECUTE FUNCTION public.tg_dreams_recount_difficulty();

-- 7) ── Витрина со средними ─────────────────────────────────────────
-- Средние считаются здесь, а не в клиенте: делить на ноль и округлять
-- в трёх местах — верный способ показать «4.7999999».
CREATE OR REPLACE VIEW public.dreams_with_stats AS
SELECT
  d.*,
  CASE WHEN d.difficulty_votes > 0
    THEN round(d.difficulty_sum::numeric / d.difficulty_votes, 1) END AS difficulty_avg,
  CASE WHEN d.worth_votes > 0
    THEN round(d.worth_sum::numeric / d.worth_votes, 1) END AS worth_avg
FROM public.dreams d
WHERE d.is_deleted = false AND d.is_approved = true;

-- 8) ── RLS ─────────────────────────────────────────────────────────
ALTER TABLE public.dreams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_difficulty_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dream_reports ENABLE ROW LEVEL SECURITY;

-- Справочник читают все: в нём нет ничего личного.
DROP POLICY IF EXISTS p_dreams_view ON public.dreams;
CREATE POLICY p_dreams_view ON public.dreams
  FOR SELECT USING (is_deleted = false AND is_approved = true);

-- INSERT/UPDATE-политик нет намеренно:
--   • вставка идёт только через find_or_create_dream — иначе клиент создаст
--     дубль в обход дедупликации, и обсуждение расколется надвое;
--   • счётчики правят только триггеры (SECURITY DEFINER обходит RLS);
--   • переименовать общую мечту нельзя — иначе один человек подменит её
--     тысяче подписчиков.

DROP POLICY IF EXISTS p_dream_follows_own ON public.dream_follows;
CREATE POLICY p_dream_follows_own ON public.dream_follows
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Чужие подписки и реплики наружу через прямой SELECT НЕ отдаются —
-- как и везде в проекте (ср. p_users_own, p_pp_own). Причина не только в
-- приватности: политика не умеет спросить is_blocked_between, поэтому
-- заблокированный человек всё равно светился бы в списке. Всё чтение
-- чужого идёт через SECURITY DEFINER RPC ниже — тот же приём, что у
-- search_users / list_friends_feed.
DROP POLICY IF EXISTS p_dream_difficulty_own ON public.dream_difficulty_votes;
CREATE POLICY p_dream_difficulty_own ON public.dream_difficulty_votes
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS p_dream_comments_own ON public.dream_comments;
CREATE POLICY p_dream_comments_own ON public.dream_comments
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS p_dream_reports_own ON public.dream_reports;
CREATE POLICY p_dream_reports_own ON public.dream_reports
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 9) ── RPC ─────────────────────────────────────────────────────────

-- Дедупликация. Клиент НИКОГДА не вставляет в dreams напрямую: иначе
-- «Прыгнуть с парашютом» и «прыгнуть с парашютом » разъедутся в две мечты
-- с одной звездой в каждой, и обсуждение расколется.
CREATE OR REPLACE FUNCTION public.find_or_create_dream(
  p_title    TEXT,
  p_category task_category DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me    UUID := auth.uid();
  v_title TEXT := btrim(p_title);
  v_id    UUID;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  IF length(v_title) = 0 THEN RAISE EXCEPTION 'empty_title'; END IF;

  SELECT id INTO v_id FROM public.dreams
   WHERE title_norm = lower(v_title) AND is_deleted = false;
  IF v_id IS NOT NULL THEN RETURN v_id; END IF;

  INSERT INTO public.dreams (title, category, created_by)
  VALUES (v_title, p_category, v_me)
  RETURNING id INTO v_id;
  RETURN v_id;
END $$;
GRANT EXECUTE ON FUNCTION public.find_or_create_dream(TEXT, task_category) TO authenticated;

-- Похожие мечты для подсказки «вы имели в виду ...?». Триграммы, а не
-- LIKE: «парашют» должен находить «Прыгнуть с парашютом».
CREATE OR REPLACE FUNCTION public.search_dreams(p_query TEXT)
RETURNS TABLE (
  id               UUID,
  title            TEXT,
  category         task_category,
  want_count       INT,
  done_count       INT,
  difficulty_avg   NUMERIC,
  worth_avg        NUMERIC,
  difficulty_votes INT,
  worth_votes      INT,
  created_at       TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_me UUID := auth.uid();
  v_q  TEXT;
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;
  v_q := lower(btrim(p_query));
  IF length(v_q) < 2 THEN RETURN; END IF;

  RETURN QUERY
    SELECT d.id, d.title, d.category, d.want_count, d.done_count,
           d.difficulty_avg, d.worth_avg, d.difficulty_votes, d.worth_votes,
           d.created_at
      FROM public.dreams_with_stats d
     WHERE d.title_norm % v_q OR d.title_norm LIKE '%' || v_q || '%'
     ORDER BY similarity(d.title_norm, v_q) DESC, d.want_count DESC
     LIMIT 10;
END $$;
GRANT EXECUTE ON FUNCTION public.search_dreams(TEXT) TO authenticated;

-- «Кто уже сделал» — только те, кто сам открылся (is_public), только
-- сделавшие, и без заблокированных.
CREATE OR REPLACE FUNCTION public.list_dream_doers(
  p_dream_id UUID,
  p_limit    INT DEFAULT 20
)
RETURNS TABLE (
  user_id            UUID,
  display_name       TEXT,
  avatar_preview_url TEXT,
  worth_rating       INT,
  note               TEXT,
  photo_url          TEXT,
  done_at            TIMESTAMPTZ
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  RETURN QUERY
    SELECT f.user_id, pp.display_name, pp.avatar_preview_url,
           f.worth_rating, f.note, f.photo_url, f.done_at
      FROM public.dream_follows f
      JOIN public.user_public_profiles pp ON pp.user_id = f.user_id
     WHERE f.dream_id = p_dream_id
       AND f.is_deleted = false
       AND f.is_public = true
       AND f.done_at IS NOT NULL
       AND NOT public.is_blocked_between(v_me, f.user_id)
     ORDER BY f.done_at DESC
     LIMIT p_limit;
END $$;
GRANT EXECUTE ON FUNCTION public.list_dream_doers(UUID, INT) TO authenticated;

-- Обсуждение. author_worth_rating подтягивается, чтобы UI отличал совет
-- прошедшего путь от мнения зрителя.
CREATE OR REPLACE FUNCTION public.list_dream_comments(
  p_dream_id UUID,
  p_limit    INT DEFAULT 50
)
RETURNS TABLE (
  id                  UUID,
  dream_id            UUID,
  user_id             UUID,
  body                TEXT,
  created_at          TIMESTAMPTZ,
  display_name        TEXT,
  avatar_preview_url  TEXT,
  author_worth_rating INT
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE v_me UUID := auth.uid();
BEGIN
  IF v_me IS NULL THEN RAISE EXCEPTION 'not_authenticated'; END IF;

  RETURN QUERY
    SELECT c.id, c.dream_id, c.user_id, c.body, c.created_at,
           pp.display_name, pp.avatar_preview_url,
           -- Оценка видна, только если автор сам открылся: иначе реплика
           -- выдала бы приватный факт «он это делал».
           CASE WHEN f.is_public THEN f.worth_rating END
      FROM public.dream_comments c
      JOIN public.user_public_profiles pp ON pp.user_id = c.user_id
      LEFT JOIN public.dream_follows f
             ON f.dream_id = c.dream_id AND f.user_id = c.user_id
            AND f.is_deleted = false AND f.done_at IS NOT NULL
     WHERE c.dream_id = p_dream_id
       AND c.is_deleted = false
       AND NOT public.is_blocked_between(v_me, c.user_id)
     ORDER BY c.created_at DESC
     LIMIT p_limit;
END $$;
GRANT EXECUTE ON FUNCTION public.list_dream_comments(UUID, INT) TO authenticated;

-- 10) ── Перенос из wishlist_items ──────────────────────────────────
-- Старую таблицу НЕ удаляем: пока клиент не переехал, она остаётся
-- источником правды на случай отката.
INSERT INTO public.dreams (title, created_by, created_at)
SELECT DISTINCT ON (lower(btrim(w.title)))
       btrim(w.title), w.user_id, w.created_at
FROM public.wishlist_items w
WHERE w.is_deleted = false AND btrim(w.title) <> ''
ORDER BY lower(btrim(w.title)), w.created_at
ON CONFLICT DO NOTHING;

INSERT INTO public.dream_follows
  (dream_id, user_id, done_at, converted_task_id, created_at)
SELECT d.id, w.user_id, w.tried_at, w.converted_task_id, w.created_at
FROM public.wishlist_items w
JOIN public.dreams d ON d.title_norm = lower(btrim(w.title))
WHERE w.is_deleted = false AND btrim(w.title) <> ''
ON CONFLICT (dream_id, user_id) DO NOTHING;
