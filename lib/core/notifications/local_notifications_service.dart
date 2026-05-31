import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();

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
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hero_tasks',
            'Tasks',
            channelDescription: 'Task reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleTaskReminder failed: $e');
    }
  }

  Future<void> cancel(int id) async {
    if (!_ready) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_ready) return;
    await _plugin.cancelAll();
  }
}

/// Helper: deterministic int id derived from a uuid string.
/// Stable across runs (uses Dart's String.hashCode).
int stableNotificationIdFor(String uuid) => uuid.hashCode.abs();
