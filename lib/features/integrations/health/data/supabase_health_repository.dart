import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import 'health_native_service.dart';

class TodayHealth {
  const TodayHealth({
    required this.steps,
    required this.distanceMeters,
    required this.workoutsCount,
    this.lastSyncAt,
  });
  final int steps;
  final double distanceMeters;
  final int workoutsCount;
  final DateTime? lastSyncAt;
}

class SupabaseHealthRepository {
  SupabaseHealthRepository(this._client);
  final SupabaseClient _client;

  Future<void> upsertDay(HealthDailyData d, String source) async {
    await _client.rpc<dynamic>(
      'upsert_health_summary',
      params: {
        'p_date': d.date.toIso8601String().split('T').first,
        'p_steps': d.steps,
        'p_distance_meters': d.distanceMeters,
        'p_workouts_count': d.workoutsCount,
        'p_source': source,
      },
    );
  }

  Future<TodayHealth> getToday() async {
    final rows = await _client.rpc<dynamic>('get_today_health');
    if (rows is List && rows.isNotEmpty) {
      final r = (rows.first as Map).cast<String, dynamic>();
      return TodayHealth(
        steps: (r['steps'] as num?)?.toInt() ?? 0,
        distanceMeters: (r['distance_meters'] as num?)?.toDouble() ?? 0,
        workoutsCount: (r['workouts_count'] as num?)?.toInt() ?? 0,
        lastSyncAt: r['last_sync_at'] == null
            ? null
            : DateTime.parse(r['last_sync_at'] as String),
      );
    }
    return const TodayHealth(steps: 0, distanceMeters: 0, workoutsCount: 0);
  }

  Future<void> disconnect(String provider) async {
    await _client.rpc<dynamic>(
      'disconnect_integration',
      params: {'p_provider': provider},
    );
  }
}

final supabaseHealthRepositoryProvider = Provider<SupabaseHealthRepository>(
  (ref) => SupabaseHealthRepository(ref.watch(supabaseClientProvider)),
);
