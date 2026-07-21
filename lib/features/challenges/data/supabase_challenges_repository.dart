import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../rewards/domain/models/unlocked_achievement.dart';
import '../domain/models/challenge.dart';
import '../domain/models/challenge_leaderboard.dart';
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

  /// Live participant count for the detail screen. RLS hides other users'
  /// participant rows, so this goes through the SECURITY DEFINER RPC
  /// `get_challenge_stats` rather than a client-side COUNT.
  Future<int> participantsCount(String challengeId) async {
    final res = await _client.rpc<dynamic>(
      'get_challenge_stats',
      params: {'p_challenge_id': challengeId},
    );
    final map =
        res is Map ? Map<String, dynamic>.from(res) : const <String, dynamic>{};
    return (map['participants_count'] as num?)?.toInt() ?? 0;
  }

  /// Ranked leaderboard for the detail screen. Goes through the
  /// SECURITY DEFINER RPC `get_challenge_leaderboard` (RLS hides other
  /// participants' rows from a direct query).
  Future<ChallengeLeaderboard> leaderboard(
    String challengeId, {
    int limit = 20,
  }) async {
    final res = await _client.rpc<dynamic>(
      'get_challenge_leaderboard',
      params: {'p_challenge_id': challengeId, 'p_limit': limit},
    );
    final map =
        res is Map ? Map<String, dynamic>.from(res) : const <String, dynamic>{};
    return ChallengeLeaderboard.fromJson(map);
  }
}

final challengesRepositoryProvider = Provider<SupabaseChallengesRepository>(
  (ref) => SupabaseChallengesRepository(ref.watch(supabaseClientProvider)),
);

/// Live participant count for a single challenge (detail screen).
final challengeParticipantsCountProvider =
    FutureProvider.family<int, String>((ref, challengeId) {
  return ref.watch(challengesRepositoryProvider).participantsCount(challengeId);
});

/// Ranked leaderboard for a single challenge (detail screen).
final challengeLeaderboardProvider =
    FutureProvider.family<ChallengeLeaderboard, String>((ref, challengeId) {
  return ref.watch(challengesRepositoryProvider).leaderboard(challengeId);
});
