import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_native_service.dart';
import '../data/supabase_health_repository.dart';

class HealthSyncService {
  HealthSyncService(this._repo);
  final SupabaseHealthRepository _repo;

  bool _running = false;

  /// Pulls the last [days] days from the native Health API and upserts
  /// each one. Each upsert RPC computes its own distance delta and
  /// forwards it to process_challenge_progress server-side. Repeated
  /// calls are safe (delta = 0 once steady).
  Future<bool> syncRecent({int days = 7}) async {
    if (_running) return false;
    _running = true;
    try {
      final hasPerm = await HealthNativeService.instance.hasPermissions();
      if (!hasPerm) return false;
      final source = HealthNativeService.instance.providerKey;
      final data =
          await HealthNativeService.instance.getLastDays(days: days);
      for (final d in data) {
        await _repo.upsertDay(d, source);
      }
      return true;
    } catch (e) {
      debugPrint('HealthSyncService err: $e');
      return false;
    } finally {
      _running = false;
    }
  }
}

final healthSyncServiceProvider = Provider<HealthSyncService>(
  (ref) => HealthSyncService(ref.watch(supabaseHealthRepositoryProvider)),
);
