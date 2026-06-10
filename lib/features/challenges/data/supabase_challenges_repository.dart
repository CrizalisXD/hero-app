import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../rewards/domain/models/unlocked_achievement.dart';
import '../domain/models/challenge.dart';
import '../domain/models/challenge_participant.dart';

/// Result of join_challenge — includes any achievements that the server
/// just unlocked (notably `challenge_first` on the first join).
class JoinChallengeResult {
  const JoinChallengeResult({required this.unlocked});
  final List<UnlockedAchievement> unlocked;
}

class SupabaseChallengesRepository {
  SupabaseChallengesRepository(this._client);
  final SupabaseClient _client;

  Future<List<Challenge>> listSystem() async {
    final rows = await _client.rpc<dynamic>('list_system_challenges');
    if (rows is! List) return const [];
    return rows
        .map((e) => Challenge.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<ChallengeParticipant>> listMine() async {
    final rows = await _client.rpc<dynamic>('list_my_challenges');
    if (rows is! List) return const [];
    return rows
        .map(
          (e) =>
              ChallengeParticipant.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList();
  }

  Future<JoinChallengeResult> join(String challengeId) async {
    final res = await _client.rpc<dynamic>(
      'join_challenge',
      params: {'p_challenge_id': challengeId},
    );
    final map = res is Map
        ? Map<String, dynamic>.from(res)
        : <String, dynamic>{};
    return JoinChallengeResult(
      unlocked: UnlockedAchievement.listFromJson(map['unlocked_achievements']),
    );
  }

  Future<void> leave(String challengeId) async {
    await _client.rpc<dynamic>(
      'leave_challenge',
      params: {'p_challenge_id': challengeId},
    );
  }
}

final challengesRepositoryProvider = Provider<SupabaseChallengesRepository>(
  (ref) => SupabaseChallengesRepository(ref.watch(supabaseClientProvider)),
);
