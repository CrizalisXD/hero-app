import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../data/device_calendar_service.dart';

/// Two-way sync between Hero tasks and the device calendar.
///
/// Runs on app foreground (HeroApp.didChangeAppLifecycleState → resumed).
/// One reconcile pass does the minimum needed for "what you see in the
/// calendar matches what you see in Hero" — no background workers, no
/// push, no cron.
///
/// Reconcile responsibilities (in order):
///
///   1. **Link-up dedupe**. For each calendar event whose id isn't
///      already on a Hero task, look for an UNLINKED Hero task with
///      the same (lowercased) title and a due_at within ±1h of the
///      event start. If found → write external_calendar_event_id onto
///      that existing task. Solves the bug where pre-existing Hero
///      tasks got imported as duplicates.
///
///   2. **Calendar → App: import**. Remaining calendar events with no
///      Hero counterpart get created as new tasks.
///
///   3. **Calendar → App: edit sync**. For tasks already linked to an
///      event, if the event's title or start has changed → update the
///      task. Calendar is treated as the source of truth on incoming
///      sync because the user edited it last in that surface.
///
///   4. **Calendar → App: delete**. Linked tasks whose event no longer
///      exists are deleted.
///
/// Out of scope (deferred to v1.1):
///   • Background sync — iOS BGTaskScheduler is heavily throttled and
///     gives ~5% extra coverage on top of foreground-on-launch
///   • Recurring events — model gap, needs its own design
class CalendarSyncAgent {
  CalendarSyncAgent(this._client);
  final SupabaseClient _client;

  bool _running = false;

  Future<bool> _preflight() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('cal_sync_tasks') != true) return false;
    final calId = prefs.getString('cal_default_id');
    if (calId == null) return false;
    return DeviceCalendarService.instance.hasPermissions();
  }

  Future<void> reconcile() async {
    if (_running) return;
    _running = true;
    try {
      if (!await _preflight()) return;

      final prefs = await SharedPreferences.getInstance();
      final calId = prefs.getString('cal_default_id')!;
      final uid = _client.auth.currentUser?.id;
      if (uid == null) return;

      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day - 1);
      final to = DateTime(now.year, now.month, now.day + 30);

      final calendarEvents = await DeviceCalendarService.instance
          .listEventsInRange(calId, from: from, to: to);
      final calendarEventsById = {
        for (final e in calendarEvents) e.id: e,
      };

      // Snapshot every task that could be involved in sync — both linked
      // ones (for delete + edit) and unlinked ones (for dedupe).
      final rows = await _client
          .from('tasks')
          .select('id, title, due_at, external_calendar_event_id')
          .eq('user_id', uid)
          .gte('due_at', from.toUtc().toIso8601String())
          .lte('due_at', to.toUtc().toIso8601String());
      final tasks = (rows as List).cast<Map<String, dynamic>>();

      final linked = <String, Map<String, dynamic>>{
        for (final t in tasks)
          if (t['external_calendar_event_id'] != null)
            t['external_calendar_event_id'] as String: t,
      };
      final unlinked = tasks
          .where((t) => t['external_calendar_event_id'] == null)
          .toList(growable: true);

      int linkedCount = 0;
      int importedCount = 0;
      int updatedCount = 0;
      int deletedCount = 0;

      // ── 1. Link-up dedupe ─────────────────────────────────────────
      for (final ev in calendarEvents) {
        if (linked.containsKey(ev.id)) continue;
        final match = _findUnlinkedMatch(unlinked, ev);
        if (match != null) {
          try {
            await _client
                .from('tasks')
                .update({'external_calendar_event_id': ev.id})
                .eq('id', match['id'] as String);
            linkedCount++;
            // Move it into the linked map so the rest of the pass
            // treats it as a normal linked task.
            match['external_calendar_event_id'] = ev.id;
            linked[ev.id] = match;
            unlinked.remove(match);
          } catch (e) {
            debugPrint('[calendar-sync] link-up err: $e');
          }
        }
      }

      // ── 2. Import remaining events that still have no Hero task ──
      for (final ev in calendarEvents) {
        if (linked.containsKey(ev.id)) continue;
        if (ev.title.trim().isEmpty) continue;
        try {
          await _client.from('tasks').insert({
            'user_id': uid,
            'title': ev.title.trim(),
            if (ev.description != null && ev.description!.trim().isNotEmpty)
              'description': ev.description!.trim(),
            'main_category': 'mind',
            'xp_reward': 20,
            'discipline_xp_reward': 0,
            'is_recurring': false,
            'due_at': ev.start.toUtc().toIso8601String(),
            'external_calendar_event_id': ev.id,
          });
          importedCount++;
        } catch (e) {
          debugPrint('[calendar-sync] import err: $e');
        }
      }

      // ── 3. Edit sync (calendar → app) ─────────────────────────────
      // Walk the linked map. If event still exists with a changed
      // title/start, pull the calendar version onto the task.
      for (final entry in linked.entries) {
        final ev = calendarEventsById[entry.key];
        if (ev == null) continue;
        final task = entry.value;

        final newTitle = ev.title.trim();
        final newDueAt = ev.start.toUtc();
        final taskTitle = (task['title'] as String).trim();
        final taskDueIso = task['due_at'] as String?;
        final taskDueAt = taskDueIso == null
            ? null
            : DateTime.parse(taskDueIso).toUtc();

        final titleChanged = newTitle != taskTitle;
        final dueChanged = taskDueAt == null ||
            (newDueAt.difference(taskDueAt).inMinutes).abs() >= 1;

        if (titleChanged || dueChanged) {
          try {
            await _client.from('tasks').update({
              if (titleChanged) 'title': newTitle,
              if (dueChanged) 'due_at': newDueAt.toIso8601String(),
            }).eq('id', task['id'] as String);
            updatedCount++;
          } catch (e) {
            debugPrint('[calendar-sync] update err: $e');
          }
        }
      }

      // ── 4. Delete tasks whose calendar event is gone ──────────────
      for (final entry in linked.entries) {
        if (!calendarEventsById.containsKey(entry.key)) {
          try {
            await _client.from('tasks').delete().eq(
                  'id',
                  entry.value['id'] as String,
                );
            deletedCount++;
          } catch (e) {
            debugPrint('[calendar-sync] delete err: $e');
          }
        }
      }

      debugPrint(
        '[calendar-sync] reconcile: linked=$linkedCount '
        'imported=$importedCount updated=$updatedCount '
        'deleted=$deletedCount',
      );
    } finally {
      _running = false;
    }
  }

  /// Heuristic match for an unlinked task that's likely the same thing
  /// as `ev`. Same lowercased title + due_at within ±1 hour of the
  /// event's start. Loose enough to catch user-edited time, strict
  /// enough to avoid false-positive merges across unrelated entries.
  Map<String, dynamic>? _findUnlinkedMatch(
    List<Map<String, dynamic>> unlinked,
    CalendarEventRef ev,
  ) {
    final evTitle = ev.title.trim().toLowerCase();
    if (evTitle.isEmpty) return null;
    final evStart = ev.start.toUtc();

    for (final t in unlinked) {
      final taskTitle = (t['title'] as String).trim().toLowerCase();
      if (taskTitle != evTitle) continue;
      final dueIso = t['due_at'] as String?;
      if (dueIso == null) continue;
      final taskDue = DateTime.parse(dueIso).toUtc();
      final diff = taskDue.difference(evStart).inMinutes.abs();
      if (diff <= 60) return t;
    }
    return null;
  }
}

final calendarSyncAgentProvider = Provider<CalendarSyncAgent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CalendarSyncAgent(client);
});
