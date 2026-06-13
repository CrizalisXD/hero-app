import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../data/device_calendar_service.dart';

/// Two-way sync between Hero tasks and the user's device calendar.
///
/// Runs on app foreground (called from HeroApp.didChangeAppLifecycleState
/// → resumed). One pass does the bare minimum: no background workers, no
/// push channels, no cron — every active install just reconciles when
/// the user opens the app.
///
/// Scope of this pass:
///
///   1. **Calendar → App (creation)**. For every event in the configured
///      default calendar within [now - 1d, now + 30d], if there's no
///      Hero task with this `external_calendar_event_id`, create one.
///      Imported tasks get main_category='mind' as a neutral default —
///      the auto-classifier doesn't run here because the user didn't
///      type the title in our UI.
///
///   2. **Calendar → App (deletion)**. For every Hero task that *has*
///      an `external_calendar_event_id`, check whether the event still
///      exists in the calendar. If not → soft-delete the task (set
///      is_done=true marker? No — we don't have soft-delete on tasks
///      yet, so this pass *physically* DELETEs the task row. RLS keeps
///      it safe).
///
/// Out of scope (left for v1.1):
///   • Title / time edits propagating either direction
///   • Conflict resolution when both sides change simultaneously
///   • Background sync (iOS BGTaskScheduler, Android WorkManager)
///   • Recurring events (we only mirror single instances right now)
class CalendarSyncAgent {
  CalendarSyncAgent(this._client);
  final SupabaseClient _client;

  bool _running = false;

  /// Quick precondition check: consents granted, sync toggle on,
  /// default calendar picked. Skip the heavy work if any are off.
  Future<bool> _preflight() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('cal_sync_tasks') != true) return false;
    final calId = prefs.getString('cal_default_id');
    if (calId == null) return false;

    final hasPerms = await DeviceCalendarService.instance.hasPermissions();
    if (!hasPerms) return false;
    return true;
  }

  /// Returns silently. All errors are swallowed — sync is best-effort,
  /// it never blocks the UI or surfaces failures to the user. Diagnostics
  /// land in `debugPrint` so Xcode/logcat can show them when needed.
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
      final calendarEventIds = {for (final e in calendarEvents) e.id};

      // ── 1. Calendar → App (delete) ───────────────────────────────
      // Tasks that we previously mirrored but the user has since
      // removed from the calendar.
      final mirrored = await _client
          .from('tasks')
          .select('id, external_calendar_event_id')
          .eq('user_id', uid)
          .not('external_calendar_event_id', 'is', null);
      final mirroredList = (mirrored as List).cast<Map<String, dynamic>>();

      int deletedTasks = 0;
      for (final row in mirroredList) {
        final eventId = row['external_calendar_event_id'] as String?;
        if (eventId == null) continue;
        if (!calendarEventIds.contains(eventId)) {
          // Event vanished from calendar → drop the task.
          try {
            await _client.from('tasks').delete().eq('id', row['id'] as String);
            deletedTasks++;
          } catch (e) {
            debugPrint('sync delete task err: $e');
          }
        }
      }

      // ── 2. Calendar → App (import) ───────────────────────────────
      // Events in the calendar that have no Hero task linked. Skip
      // events that originated from us (we'd recognize our own
      // external_calendar_event_id) — already filtered above by the
      // EXISTS check we'll do.
      final existingLinks = mirroredList
          .map((r) => r['external_calendar_event_id'] as String?)
          .whereType<String>()
          .toSet();

      int importedTasks = 0;
      for (final ev in calendarEvents) {
        if (existingLinks.contains(ev.id)) continue;
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
          importedTasks++;
        } catch (e) {
          debugPrint('sync import task err: $e');
        }
      }

      debugPrint(
        '[calendar-sync] reconcile done: '
        'deleted=$deletedTasks imported=$importedTasks',
      );
    } finally {
      _running = false;
    }
  }
}

final calendarSyncAgentProvider = Provider<CalendarSyncAgent>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CalendarSyncAgent(client);
});
