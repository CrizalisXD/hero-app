import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications`.
///
/// Singleton initialised once at app start (`main.dart`).
/// All `schedule*` calls become no-ops until `init()` succeeded —
/// so callers don't have to await readiness.
class LocalNotificationsService {
  LocalNotificationsService._();
  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  // ── Android channels (Phase 20) ─────────────────────────────────────
  static const channelTasks = 'hero_tasks';
  static const channelHabits = 'hero_habits';
  static const channelGoals = 'hero_goals';
  static const channelRoutines = 'hero_routines';
  static const channelSystem = 'hero_system';

  /// Channel id for an entity type. Defaults to the system channel.
  static String channelForEntity(String entityType) => switch (entityType) {
        'task' => channelTasks,
        'habit' => channelHabits,
        'goal' => channelGoals,
        'routine' => channelRoutines,
        _ => channelSystem,
      };

  // iOS: show the alert/sound even while the app is in the foreground —
  // otherwise a scheduled notification fires silently when the app is open.
  static const _iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    presentBanner: true,
  );

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    // Without this, tz.local stays UTC and repeating reminders fire at the
    // wrong wall-clock time (off by the device's UTC offset).
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('tz.setLocalLocation failed: $e');
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // We request permissions explicitly via [requestPermission].
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(initSettings);
    _ready = true;
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> isPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Schedule a local reminder. `id` MUST be stable (e.g. hash from task uuid)
  /// so a later [cancel] call can target the same notification.
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    if (!_ready) return;
    if (at.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        _details(
          channelId: channelTasks,
          channelName: 'Tasks',
          channelDesc: 'Task reminders',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleTaskReminder failed: $e');
    }
  }

  // ── Phase 20: shared details builder ────────────────────────────────

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDesc,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: _iosDetails,
    );
  }

  String _channelName(String channelId) => switch (channelId) {
        channelTasks => 'Tasks',
        channelHabits => 'Habits',
        channelGoals => 'Goals',
        channelRoutines => 'Routines',
        _ => 'Notifications',
      };

  // ── One-shot reminders ──────────────────────────────────────────────

  Future<void> scheduleHabitReminder({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) =>
      _scheduleOneShot(
        id: id,
        title: title,
        body: body,
        at: at,
        channelId: channelHabits,
      );

  Future<void> scheduleGoalReminder({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) =>
      _scheduleOneShot(
        id: id,
        title: title,
        body: body,
        at: at,
        channelId: channelGoals,
      );

  Future<void> _scheduleOneShot({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String channelId,
  }) async {
    if (!_ready || at.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(at, tz.local),
        _details(
          channelId: channelId,
          channelName: _channelName(channelId),
          channelDesc: '${_channelName(channelId)} reminders',
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('_scheduleOneShot($channelId) failed: $e');
    }
  }

  // ── Repeating reminders ─────────────────────────────────────────────

  /// Schedules a repeating notification anchored to a time of day.
  /// [recurrence]: 'daily' | 'weekly' | 'weekdays' | 'weekends'.
  /// For 'weekly' pass [weekday] (1=Mon … 7=Sun). 'weekdays'/'weekends' fan
  /// out to one OS-repeating notification per day (ids [id]+weekday) using
  /// `dayOfWeekAndTime`, which survives reboots better than periodicallyShow.
  Future<void> scheduleRepeating({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String recurrence,
    required TimeOfDay timeOfDay,
    int? weekday,
  }) async {
    if (!_ready) return;
    final details = _details(
      channelId: channelId,
      channelName: _channelName(channelId),
      channelDesc: '${_channelName(channelId)} reminders',
    );

    try {
      switch (recurrence) {
        case 'daily':
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            _nextInstanceOf(timeOfDay),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
        case 'weekly':
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            _nextInstanceOf(timeOfDay, weekday: weekday ?? DateTime.monday),
            details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        case 'weekdays':
          for (final d in const [1, 2, 3, 4, 5]) {
            await _plugin.zonedSchedule(
              id + d,
              title,
              body,
              _nextInstanceOf(timeOfDay, weekday: d),
              details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
        case 'weekends':
          for (final d in const [6, 7]) {
            await _plugin.zonedSchedule(
              id + d,
              title,
              body,
              _nextInstanceOf(timeOfDay, weekday: d),
              details,
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
      }
    } catch (e) {
      debugPrint('scheduleRepeating($recurrence) failed: $e');
    }
  }

  /// Placeholder for Phase 21 routines — daily repeating reminder.
  Future<void> scheduleRoutineReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay at,
  }) =>
      scheduleRepeating(
        id: id,
        title: title,
        body: body,
        channelId: channelRoutines,
        recurrence: 'daily',
        timeOfDay: at,
      );

  /// Next future occurrence of [time] (optionally on [weekday], 1=Mon…7=Sun).
  tz.TZDateTime _nextInstanceOf(TimeOfDay time, {int? weekday}) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (weekday != null) {
      while (scheduled.weekday != weekday) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(Duration(days: weekday == null ? 1 : 7));
    }
    return scheduled;
  }

  // ── Quiet hours ─────────────────────────────────────────────────────

  /// True if [dt]'s time-of-day falls inside the quiet window.
  /// [quietStart]/[quietEnd] are 'HH:MM'. Handles windows crossing midnight.
  bool isQuietHour(DateTime dt, String quietStart, String quietEnd) {
    final start = _parseHHMM(quietStart);
    final end = _parseHHMM(quietEnd);
    final now = dt.hour * 60 + dt.minute;
    if (start <= end) {
      return now >= start && now < end;
    }
    return now >= start || now < end;
  }

  int _parseHHMM(String s) {
    final parts = s.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
  }

  /// Cancels a reminder and any per-day fan-out it may have created
  /// (weekdays/weekends schedule ids [id]+1 … [id]+7).
  Future<void> cancelReminder(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
    for (var d = 1; d <= 7; d++) {
      await _plugin.cancel(id + d);
    }
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}

/// Helper: deterministic int id derived from a uuid string.
/// Stable across runs (uses Dart's String.hashCode).
int stableNotificationIdFor(String uuid) => uuid.hashCode.abs();

/// Like [stableNotificationIdFor] but offsets by entity type so a task and a
/// habit whose uuids hash alike can't collide on the same notification id.
/// Each type gets a 100k id band. The base id is capped at band-8 so the
/// per-day fan-out (+1…+7) can never overflow into the next band.
int notificationIdFor(String uuid, String entityType) {
  final offset = switch (entityType) {
    'task' => 0,
    'habit' => 100000,
    'goal' => 200000,
    'routine' => 300000,
    _ => 400000,
  };
  return (uuid.hashCode.abs() % (100000 - 8)) + offset;
}
