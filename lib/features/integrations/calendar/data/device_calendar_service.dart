import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

class TodayCalendarEvent {
  const TodayCalendarEvent({
    required this.title,
    required this.start,
    required this.end,
  });
  final String title;
  final DateTime start;
  final DateTime end;
}

/// Thin wrapper around `device_calendar`. Singleton — the plugin
/// holds platform channel state.
class DeviceCalendarService {
  DeviceCalendarService._();
  static final DeviceCalendarService instance = DeviceCalendarService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();

  Future<bool> requestPermissions() async {
    final perm = await _plugin.requestPermissions();
    return perm.isSuccess && (perm.data ?? false);
  }

  Future<bool> hasPermissions() async {
    final perm = await _plugin.hasPermissions();
    return perm.isSuccess && (perm.data ?? false);
  }

  Future<List<Calendar>> listCalendars() async {
    final res = await _plugin.retrieveCalendars();
    return res.data ?? const [];
  }

  Future<Calendar?> defaultWritableCalendar() async {
    final list = await listCalendars();
    for (final c in list) {
      if (c.isReadOnly == false && (c.isDefault ?? false)) return c;
    }
    for (final c in list) {
      if (c.isReadOnly == false) return c;
    }
    return null;
  }

  Future<List<TodayCalendarEvent>> getTodayEvents(String calendarId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final res = await _plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: start, endDate: end),
    );
    final events = res.data ?? <Event>[];
    return events
        .where((e) => e.start != null && e.end != null)
        .map(
          (e) => TodayCalendarEvent(
            title: e.title ?? '',
            start: e.start!.toLocal(),
            end: e.end!.toLocal(),
          ),
        )
        .toList();
  }

  /// Creates a calendar event for the given task. Returns the native
  /// event id, or null on failure (call site treats it as best-effort —
  /// never blocks task creation).
  Future<String?> createEventForTask({
    required String calendarId,
    required String title,
    String? notes,
    required DateTime startAt,
    DateTime? endAt,
  }) async {
    try {
      // tz.local is initialised by LocalNotificationsService at app start
      // (Phase 11). Falls back to UTC if init was skipped.
      final loc = _safeLocal();
      final ev = Event(
        calendarId,
        title: title,
        description: notes,
        start: tz.TZDateTime.from(startAt, loc),
        end: tz.TZDateTime.from(
          endAt ?? startAt.add(const Duration(minutes: 30)),
          loc,
        ),
      );
      final res = await _plugin.createOrUpdateEvent(ev);
      if (res?.isSuccess == true) return res!.data;
    } catch (e) {
      debugPrint('createEventForTask err: $e');
    }
    return null;
  }

  tz.Location _safeLocal() {
    try {
      return tz.local;
    } catch (_) {
      return tz.UTC;
    }
  }
}
