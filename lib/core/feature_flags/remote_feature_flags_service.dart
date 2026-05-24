import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote_feature_flags.dart';

class RemoteFeatureFlagsService {
  RemoteFeatureFlagsService(this._client);
  final SupabaseClient _client;

  static const Duration _ttl = Duration(hours: 1);

  RemoteFeatureFlags? _cache;

  /// Возвращает кэш если свежий, иначе запрашивает БД.
  /// При ошибке БД — возвращает прошлый кэш либо пустой snapshot.
  Future<RemoteFeatureFlags> get({bool force = false}) async {
    if (!force &&
        _cache != null &&
        DateTime.now().difference(_cache!.fetchedAt) < _ttl) {
      return _cache!;
    }
    try {
      final rows = await _client.from('feature_flags').select();
      final map = <String, FeatureFlagEntry>{};
      for (final r in (rows as List)) {
        final e = FeatureFlagEntry.fromJson(r as Map<String, dynamic>);
        map[e.key] = e;
      }
      _cache = RemoteFeatureFlags(map, fetchedAt: DateTime.now());
      return _cache!;
    } catch (e) {
      debugPrint('feature_flags load failed: $e');
      // graceful fallback — возвращаем старый кэш или пустой snapshot
      return _cache ??
          RemoteFeatureFlags(const {}, fetchedAt: DateTime.now());
    }
  }

  void invalidate() => _cache = null;
}
