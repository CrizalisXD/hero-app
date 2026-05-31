import '../../../rewards/domain/models/unlocked_achievement.dart';

class HabitCheckinResult {
  const HabitCheckinResult({
    required this.habitId,
    required this.duplicate,
    required this.xpGained,
    required this.disciplineXp,
    required this.currentStreak,
    required this.levelBefore,
    required this.levelAfter,
    required this.levelsGained,
    this.unlockedAchievements = const [],
  });

  final String habitId;
  final bool duplicate;
  final int xpGained;
  final int disciplineXp;
  final int currentStreak;
  final int levelBefore;
  final int levelAfter;
  final int levelsGained;
  final List<UnlockedAchievement> unlockedAchievements;

  int get totalXp => xpGained + disciplineXp;

  factory HabitCheckinResult.fromRpc(Map<String, dynamic> json) {
    final char = (json['character'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    return HabitCheckinResult(
      habitId: json['habit_id'] as String,
      duplicate: json['duplicate'] as bool? ?? false,
      xpGained: (json['category_xp'] as num?)?.toInt() ?? 0,
      disciplineXp: (json['discipline_xp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      levelBefore: (char['level_before'] as num?)?.toInt() ?? 0,
      levelAfter: (char['level_after'] as num?)?.toInt() ?? 0,
      levelsGained: (char['levels_gained'] as num?)?.toInt() ?? 0,
      unlockedAchievements:
          UnlockedAchievement.listFromJson(json['unlocked_achievements']),
    );
  }
}
