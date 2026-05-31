import 'achievement.dart';

/// Minimal payload returned in `unlocked_achievements: [...]` from
/// `complete_task` / `complete_habit_checkin`. Just enough info to render
/// the AchievementUnlockedSheet without an extra round trip.
class UnlockedAchievement {
  const UnlockedAchievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.rarity,
    required this.iconKey,
    required this.rewardXp,
    required this.rewardCoins,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final AchievementRarity rarity;
  final String iconKey;
  final int rewardXp;
  final int rewardCoins;

  factory UnlockedAchievement.fromJson(Map<String, dynamic> j) =>
      UnlockedAchievement(
        id: j['id'] as String,
        titleKey: j['title_key'] as String,
        descriptionKey: j['description_key'] as String,
        rarity: rarityFromWire(j['rarity'] as String? ?? 'common'),
        iconKey: j['icon_key'] as String? ?? 'star',
        rewardXp: (j['reward_xp'] as num?)?.toInt() ?? 0,
        rewardCoins: (j['reward_coins'] as num?)?.toInt() ?? 0,
      );

  static List<UnlockedAchievement> listFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => UnlockedAchievement.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
