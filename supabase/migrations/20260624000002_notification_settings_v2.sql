-- ════════════════════════════════════════════════════════════════════
-- Hero — 20260624000002_notification_settings_v2.sql
-- Phase 20 — Reminders 2.0: per-type toggles + entity_reminders table.
-- Additive only. FK targets public.users(id) to match notification_settings
-- (the TZ said profiles(id); both alias auth.users(id), but users(id) is the
-- project convention for user_id columns).
-- ════════════════════════════════════════════════════════════════════

-- New per-type switches
ALTER TABLE public.notification_settings
  ADD COLUMN IF NOT EXISTS goals_enabled    BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS routines_enabled BOOLEAN NOT NULL DEFAULT true;

-- Per-entity user reminders
CREATE TABLE IF NOT EXISTS public.entity_reminders (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entity_type     TEXT NOT NULL CHECK (entity_type IN ('task', 'habit', 'goal', 'routine')),
  entity_id       UUID NOT NULL,
  remind_at       TIMESTAMPTZ,           -- one-shot absolute time
  lead_minutes    INT,                   -- N minutes before a task's due_at
  recurrence      TEXT CHECK (recurrence IS NULL OR recurrence IN ('daily','weekly','weekdays','weekends','custom')),
  recurrence_days TEXT[],                -- for 'custom': ['mon','wed','fri']
  time_of_day     TIME,                  -- for repeating (no date)
  is_active       BOOLEAN NOT NULL DEFAULT true,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE public.entity_reminders ENABLE ROW LEVEL SECURITY;

CREATE POLICY p_entity_reminders_own ON public.entity_reminders
  FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE INDEX IF NOT EXISTS idx_entity_reminders_entity
  ON public.entity_reminders(user_id, entity_type, entity_id);

-- ════════════════════════════════════════════════════════════════════
-- END OF MIGRATION
-- ════════════════════════════════════════════════════════════════════
