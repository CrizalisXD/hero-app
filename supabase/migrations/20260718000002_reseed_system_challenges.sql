-- ════════════════════════════════════════════════════════════════════
-- Реанимация системных челленджей — вкладка «Все» была пустой.
--
-- Недельные челленджи заводились с датами DATE_TRUNC('week', CURRENT_DATE),
-- вычисленными В МОМЕНТ применения миграции (май). Поскольку миграция
-- применяется один раз, их окно так и осталось в мае и давно истекло, а
-- list_system_challenges показывает только активные (now() BETWEEN
-- start_at AND end_at). Постоянные и сезонный челленджи фиксированы и
-- должны быть активны — на всякий случай переустанавливаем и их.
--
-- UPSERT (ON CONFLICT DO UPDATE): если челлендж есть — чиним даты и
-- активность, если по какой-то причине отсутствует — создаём. Так вкладка
-- «Все» наполнится независимо от текущего состояния базы.
--
-- ВНИМАНИЕ: недельные снова устареют через неделю — это разовая
-- реанимация. Постоянное решение — авто-прокат недельных окон (pg_cron
-- или еженедельная edge-функция); вынесено отдельно.
-- ════════════════════════════════════════════════════════════════════

-- Недельные: текущая календарная неделя (Пн–Вс) на момент применения.
INSERT INTO public.challenges (
  id, challenge_type, metric_type, title_key, description_key,
  start_at, end_at, target_value, reward_xp, is_public, is_active
) VALUES
  (
    '22222222-2222-2222-2222-200000000001'::uuid,
    'weekly', 'count',
    'challengeWeeklyTasksTitle', 'challengeWeeklyTasksBody',
    DATE_TRUNC('week', now())::TIMESTAMPTZ,
    (DATE_TRUNC('week', now()) + INTERVAL '7 days')::TIMESTAMPTZ,
    10, 100, true, true
  ),
  (
    '22222222-2222-2222-2222-200000000002'::uuid,
    'weekly', 'activity_day',
    'challengeWeeklyActiveDaysTitle', 'challengeWeeklyActiveDaysBody',
    DATE_TRUNC('week', now())::TIMESTAMPTZ,
    (DATE_TRUNC('week', now()) + INTERVAL '7 days')::TIMESTAMPTZ,
    5, 80, true, true
  )
ON CONFLICT (id) DO UPDATE SET
  start_at  = EXCLUDED.start_at,
  end_at    = EXCLUDED.end_at,
  is_active = true;

-- Сезонный «Лето 2026»: июнь–август. Фиксированные даты — переустанавливаем
-- на случай, если запись отсутствует или деактивирована.
INSERT INTO public.challenges (
  id, challenge_type, metric_type, title_key, description_key,
  start_at, end_at, target_value, reward_xp, is_public, is_active
) VALUES (
  '33333333-3333-3333-3333-300000000001'::uuid,
  'seasonal', 'count',
  'challengeSummer2026Title', 'challengeSummer2026Body',
  '2026-06-01 00:00:00+00'::TIMESTAMPTZ,
  '2026-08-31 23:59:59+00'::TIMESTAMPTZ,
  100, 500, true, true
)
ON CONFLICT (id) DO UPDATE SET
  start_at  = EXCLUDED.start_at,
  end_at    = EXCLUDED.end_at,
  is_active = true;

-- Постоянные системные (2026–2099).
INSERT INTO public.challenges (
  id, challenge_type, metric_type, title_key, description_key,
  start_at, end_at, target_value, reward_xp, is_active
) VALUES
  ('11111111-1111-1111-1111-100000000001',
   'system', 'activity_day',
   'challengeSevenDaysActivityTitle', 'challengeSevenDaysActivityBody',
   '2026-01-01 00:00:00+00', '2099-12-31 23:59:59+00',
   7, 200, true),
  ('11111111-1111-1111-1111-100000000002',
   'system', 'distance',
   'challengeMonthlyStepsTitle', 'challengeMonthlyStepsBody',
   '2026-01-01 00:00:00+00', '2099-12-31 23:59:59+00',
   30000, 500, true)
ON CONFLICT (id) DO UPDATE SET
  is_active = true;
