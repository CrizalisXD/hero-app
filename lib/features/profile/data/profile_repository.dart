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
  Future<ProfileOverview> loadOverview() async {
    final results = await Future.wait<dynamic>([
      _client.from('users').select('display_name, email').single(),
      _client
          .from('character_stats')
          .select('level, xp_current, xp_to_next, xp_total, energy, energy_max')
          .single(),
      _client.from('avatars').select('primary_color').single(),
      _client.from('category_progress').select('category, xp_total, level'),
      _client.from('meta_stats').select().single(),
    ]);

    final userRow = results[0] as Map<String, dynamic>;
    final stats = results[1] as Map<String, dynamic>;
    final avatar = results[2] as Map<String, dynamic>;
    final cats = (results[3] as List)
        .map((e) => CategoryProgress.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = MetaStats.fromJson(results[4] as Map<String, dynamic>);

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
