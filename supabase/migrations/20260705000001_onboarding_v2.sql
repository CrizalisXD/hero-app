-- Онбординг v2: предпочитаемое время суток для напоминаний.
-- display_name уже существует в public.users; сюда добавляется только
-- новое поле. Пишется edge-функцией onboarding-bootstrap.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS preferred_focus_time TEXT
    CHECK (preferred_focus_time IN ('morning', 'afternoon', 'evening'));

COMMENT ON COLUMN public.users.preferred_focus_time IS
  'Онбординг v2: когда пользователю удобнее заниматься собой — дефолт для времени напоминаний привычек.';
