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
      return await Health()
          .requestAuthorization(_types, permissions: perms);
    } catch (e) {
      debugPrint('Health requestAuthorization err: $e');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    await _configure();
    return (await Health().hasPermissions(_types)) ?? false;
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
