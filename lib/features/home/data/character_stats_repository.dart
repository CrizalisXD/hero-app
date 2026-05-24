import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class CharacterStats {
  const CharacterStats({
    required this.level,
    required this.xpCurrent,
    required this.xpToNext,
    required this.xpTotal,
    required this.energy,
    required this.energyMax,
  });

  final int level;
  final int xpCurrent;
  final int xpToNext;
  final int xpTotal;
  final int energy;
  final int energyMax;

  double get xpProgress =>
      xpToNext == 0 ? 0 : (xpCurrent / xpToNext).clamp(0.0, 1.0);

  double get energyProgress =>
      energyMax == 0 ? 0 : (energy / energyMax).clamp(0.0, 1.0);

  factory CharacterStats.fromJson(Map<String, dynamic> j) => CharacterStats(
        level: (j['level'] as num?)?.toInt() ?? 1,
        xpCurrent: (j['xp_current'] as num?)?.toInt() ?? 0,
        xpToNext: (j['xp_to_next'] as num?)?.toInt() ?? 200,
        xpTotal: (j['xp_total'] as num?)?.toInt() ?? 0,
        energy: (j['energy'] as num?)?.toInt() ?? 100,
        energyMax: (j['energy_max'] as num?)?.toInt() ?? 100,
      );
}

class CharacterStatsRepository {
  CharacterStatsRepository(this._client);
  final SupabaseClient _client;

  Future<CharacterStats> getMy() async {
    final row = await _client
        .from('character_stats')
        .select()
        .single();
    return CharacterStats.fromJson(row);
  }
}

final characterStatsRepositoryProvider =
    Provider<CharacterStatsRepository>((ref) {
  return CharacterStatsRepository(ref.watch(supabaseClientProvider));
});
