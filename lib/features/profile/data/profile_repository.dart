import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../domain/models/profile_overview.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  /// Pulls everything the profile screen needs in one parallel batch.
  ///
  /// Only character_stats is critical — without level/XP there is nothing
  /// to render. If it is missing (fresh/just-switched session that beat
  /// ensure_user_bootstrap), the idempotent bootstrap RPC runs once and the
  /// batch refetches. Every other source degrades to defaults so a single
  /// missing row can't take down the whole screen.
  Future<ProfileOverview> loadOverview() async {
    try {
      final overview = await _fetchOverview();
      if (overview != null) return overview;
    } catch (_) {/* fall through to the bootstrap retry */}
    try {
      await _client.rpc<dynamic>('ensure_user_bootstrap');
    } catch (_) {/* let the refetch below surface the real error */}
    final overview = await _fetchOverview();
    if (overview == null) {
      throw StateError('character_stats missing after bootstrap');
    }
    return overview;
  }

  Future<ProfileOverview?> _fetchOverview() async {
    final results = await Future.wait<dynamic>([
      _orElse<Map<String, dynamic>?>(
        _client.from('users').select('display_name, email').maybeSingle(),
        null,
      ),
      _client
          .from('character_stats')
          .select('level, xp_current, xp_to_next, xp_total, energy, energy_max')
          .maybeSingle(),
      _orElse<Map<String, dynamic>?>(
        _client.from('avatars').select('primary_color').maybeSingle(),
        null,
      ),
      _orElse<List<dynamic>>(
        _client.from('category_progress').select('category, xp_total, level'),
        const <dynamic>[],
      ),
      _orElse<Map<String, dynamic>?>(
        _client.from('meta_stats').select().maybeSingle(),
        null,
      ),
    ]);

    final stats = results[1] as Map<String, dynamic>?;
    if (stats == null) return null;

    final userRow = results[0] as Map<String, dynamic>? ?? const {};
    final avatar = results[2] as Map<String, dynamic>? ?? const {};
    final cats = (results[3] as List)
        .map((e) => CategoryProgress.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta =
        MetaStats.fromJson(results[4] as Map<String, dynamic>? ?? const {});

    return ProfileOverview(
      displayName: userRow['display_name'] as String? ?? 'Hero',
      email: userRow['email'] as String?,
      level: (stats['level'] as num?)?.toInt() ?? 1,
      xpCurrent: (stats['xp_current'] as num?)?.toInt() ?? 0,
      xpToNext: (stats['xp_to_next'] as num?)?.toInt() ?? 200,
      xpTotal: (stats['xp_total'] as num?)?.toInt() ?? 0,
      energy: (stats['energy'] as num?)?.toInt() ?? 100,
      energyMax: (stats['energy_max'] as num?)?.toInt() ?? 100,
      avatarPrimaryColor: avatar['primary_color'] as String? ?? '#7F77DD',
      categories: cats,
      metaStats: meta,
    );
  }

  static Future<T> _orElse<T>(Future<T> future, T fallback) async {
    try {
      return await future;
    } catch (_) {
      return fallback;
    }
  }

  Future<void> updateDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await _client
        .from('users')
        .update({'display_name': trimmed})
        .eq('id', _uid);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});
