import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/achievements_repository.dart';
import '../domain/models/achievement.dart';
import '../domain/models/user_achievement.dart';

class SupabaseAchievementsRepository implements AchievementsRepository {
  SupabaseAchievementsRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Achievement>> listAll() async {
    final rows =
        await _client.from('achievements').select().order('sort_order');
    return (rows as List)
        .map((e) => Achievement.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<UserAchievement>> listMyUnlocked() async {
    final rows = await _client
        .from('user_achievements')
        .select()
        .order('unlocked_at', ascending: false);
    return (rows as List)
        .map((e) => UserAchievement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final achievementsRepositoryProvider = Provider<AchievementsRepository>(
  (ref) => SupabaseAchievementsRepository(ref.watch(supabaseClientProvider)),
);
