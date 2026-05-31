/// Per-user unlock row from `public.user_achievements`.
class UserAchievement {
  const UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    required this.progressValue,
    required this.isClaimed,
  });

  final String userId;
  final String achievementId;
  final DateTime unlockedAt;
  final num progressValue;
  final bool isClaimed;

  factory UserAchievement.fromJson(Map<String, dynamic> j) => UserAchievement(
        userId: j['user_id'] as String,
        achievementId: j['achievement_id'] as String,
        unlockedAt: DateTime.parse(j['unlocked_at'] as String),
        progressValue: (j['progress_value'] as num?) ?? 0,
        isClaimed: j['is_claimed'] as bool? ?? false,
      );
}
