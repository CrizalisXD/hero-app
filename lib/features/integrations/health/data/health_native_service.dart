import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// One-day aggregate read from the native Health API.
class HealthDailyData {
  const HealthDailyData({
    required this.date,
    required this.steps,
    required this.distanceMeters,
    required this.workoutsCount,
  });

  final DateTime date;
  final int steps;
  final double distanceMeters;
  final int workoutsCount;
}

/// Thin wrapper around the `health` plugin (HealthKit on iOS,
/// Health Connect on Android). Singleton — Health() is itself a
/// singleton-ish handle and only one `configure()` per process.
class HealthNativeService {
  HealthNativeService._();
  static final HealthNativeService instance = HealthNativeService._();

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.WORKOUT,
  ];

  bool _configured = false;

  Future<void> _configure() async {
    if (_configured) return;
    await Health().configure();
    _configured = true;
  }

  /// Wire string passed to `upsert_health_summary`.
  /// Matches the CHECK constraint in migration 0010.
  String get providerKey =>
      Platform.isIOS ? 'apple_health' : 'health_connect';

  Future<bool> requestPermissions() async {
    await _configure();
    final perms =
        List<HealthDataAccess>.filled(_types.length, HealthDataAccess.READ);
    try {
      // On iOS: requestAuthorization returns true after the system
      // dialog has been shown, regardless of READ/WRITE choice
      // (Apple intentionally hides whether READ was granted to prevent
      // fingerprinting). The only reliable signal that we actually
      // have access is being able to read a sample — so we always
      // probe afterwards. See [hasPermissions].
      final ok = await Health()
          .requestAuthorization(_types, permissions: perms);
      if (!ok) return false;
      // Probe: if we can pull a record (even from 7 days back), we
      // know the user has at least one read scope active.
      return await _probeReadable();
    } catch (e) {
      debugPrint('Health requestAuthorization err: $e');
      return false;
    }
  }

  /// iOS HealthKit DOES NOT expose READ permission state by design
  /// (privacy / anti-fingerprinting). `Health().hasPermissions` returns
  /// null/false even after the user grants READ via system Settings,
  /// which is what caused the "Доступ запрещён" Phase 18 bug: user
  /// manually allowed it, app still said no.
  ///
  /// Fix: don't trust hasPermissions on iOS. Instead probe — try to
  /// read one sample from the last 7 days. If that succeeds, we have
  /// access. On Android (Health Connect) hasPermissions works fine
  /// and we keep it.
  Future<bool> hasPermissions() async {
    await _configure();
    if (Platform.isAndroid) {
      return (await Health().hasPermissions(_types)) ?? false;
    }
    return _probeReadable();
  }

  /// Tries to read at least one HealthKit sample from the past week.
  /// Returns true if the API answered without an authorization error,
  /// even if the bucket is empty (a healthy phone that just has no
  /// steps logged still proves we have read access).
  Future<bool> _probeReadable() async {
    try {
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 7));
      // getHealthDataFromTypes throws PlatformException on iOS when
      // there's no authorization. Empty list = "no data but we asked
      // successfully" = read scope IS granted.
      await Health().getHealthDataFromTypes(
        startTime: start,
        endTime: now,
        types: _types,
      );
      return true;
    } catch (e) {
      debugPrint('Health probe failed: $e');
      return false;
    }
  }

  /// Aggregates the last [days] calendar days. Per-sample reads are
  /// summed into one row per local date so the upsert RPC has the
  /// shape it expects.
  Future<List<HealthDailyData>> getLastDays({int days = 7}) async {
    await _configure();
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));

    final raw = await Health().getHealthDataFromTypes(
      startTime: start,
      endTime: endOfToday,
      types: _types,
    );

    final byDate = <String, Map<String, num>>{};
    for (final h in raw) {
      final d = DateTime(h.dateFrom.year, h.dateFrom.month, h.dateFrom.day);
      final key = d.toIso8601String().split('T').first;
      final bucket = byDate.putIfAbsent(
        key,
        () => {'steps': 0, 'distance': 0, 'workouts': 0},
      );
      switch (h.type) {
        case HealthDataType.STEPS:
          bucket['steps'] = (bucket['steps'] ?? 0) + _asNum(h.value);
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          bucket['distance'] = (bucket['distance'] ?? 0) + _asNum(h.value);
        case HealthDataType.WORKOUT:
          bucket['workouts'] = (bucket['workouts'] ?? 0) + 1;
        default:
          break;
      }
    }

    // STEPS: raw samples overlap across sources (iPhone + Watch + apps),
    // so the summation above double-counts. getTotalStepsInInterval lets
    // the platform apply its own source dedup/priority — overwrite the
    // summed value with the authoritative total per day (keeping the raw
    // sum only as a fallback when the totals API fails).
    for (var i = 0; i < days; i++) {
      final dayStart = DateTime(now.year, now.month, now.day - (days - 1) + i);
      final dayEnd = i == days - 1
          ? endOfToday
          : DateTime(dayStart.year, dayStart.month, dayStart.day, 23, 59, 59);
      final key = dayStart.toIso8601String().split('T').first;
      try {
        final total = await Health().getTotalStepsInInterval(dayStart, dayEnd);
        if (total != null && (total > 0 || byDate.containsKey(key))) {
          byDate.putIfAbsent(
            key,
            () => {'steps': 0, 'distance': 0, 'workouts': 0},
          )['steps'] = total;
        }
      } catch (e) {
        debugPrint('getTotalStepsInInterval($key) failed: $e');
      }
    }

    return byDate.entries.map((e) {
      final d = DateTime.parse(e.key);
      return HealthDailyData(
        date: d,
        steps: e.value['steps']?.toInt() ?? 0,
        distanceMeters: (e.value['distance'] ?? 0).toDouble(),
        workoutsCount: e.value['workouts']?.toInt() ?? 0,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  num _asNum(HealthValue v) {
    if (v is NumericHealthValue) return v.numericValue;
    return 0;
  }
}
