/// One ranked row from `get_challenge_leaderboard`.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.progress,
    required this.isMe,
  });

  final int rank;
  final String userId;
  final String displayName;
  final num progress;
  final bool isMe;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: (j['rank'] as num?)?.toInt() ?? 0,
        userId: j['user_id'] as String? ?? '',
        displayName: j['display_name'] as String? ?? 'Hero',
        progress: (j['progress'] as num?) ?? 0,
        isMe: j['is_me'] as bool? ?? false,
      );
}

/// Full leaderboard payload: top entries + the caller's rank + total count.
class ChallengeLeaderboard {
  const ChallengeLeaderboard({
    required this.total,
    required this.myRank,
    required this.entries,
  });

  final int total;
  final int? myRank;
  final List<LeaderboardEntry> entries;

  bool get isEmpty => entries.isEmpty;

  /// True when the caller is ranked but sits below the returned top slice.
  bool get myRankBelowList => myRank != null && !entries.any((e) => e.isMe);

  factory ChallengeLeaderboard.fromJson(Map<String, dynamic> j) {
    final rawEntries = j['entries'];
    return ChallengeLeaderboard(
      total: (j['total'] as num?)?.toInt() ?? 0,
      myRank: (j['my_rank'] as num?)?.toInt(),
      entries: rawEntries is List
          ? rawEntries
              .map(
                (e) => LeaderboardEntry.fromJson(
                  (e as Map).cast<String, dynamic>(),
                ),
              )
              .toList()
          : const [],
    );
  }
}
