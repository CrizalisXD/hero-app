-- ════════════════════════════════════════════════════════════════════
-- Hero — 0018_tasks_external_calendar_event.sql
--
-- Adds the link between a Hero task and its mirrored event in the
-- device calendar, enabling true 2-way sync:
--
--   external_calendar_event_id  TEXT NULL
--     • set when the task is mirrored to the system calendar (Phase 15
--       Calendar feature)
--     • used by CalendarSyncAgent on app foreground to:
--         a) detect events deleted in the calendar → soft-delete the
--            matching Hero task (no orphaned tasks)
--         b) detect events created in the calendar → import as a new
--            Hero task (so quick-add from system calendar shows up)
--
-- Nullable: most tasks never get mirrored (consent off, no default
-- calendar). The column stays NULL in that case and is ignored by the
-- sync agent.
-- ════════════════════════════════════════════════════════════════════

ALTER TABLE public.tasks
  ADD COLUMN IF NOT EXISTS external_calendar_event_id TEXT;

-- Per-user lookup index — the sync agent queries
-- WHERE user_id = $1 AND external_calendar_event_id IS NOT NULL.
CREATE INDEX IF NOT EXISTS idx_tasks_user_calendar_event
  ON public.tasks (user_id, external_calendar_event_id)
  WHERE external_calendar_event_id IS NOT NULL;
