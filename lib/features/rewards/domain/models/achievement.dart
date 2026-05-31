enum AchievementRarity { common, rare, epic, legendary }

enum AchievementCategoryGroup {
  streak,
  level,
  task,
  habit,
  goal,
  social,
  challenge,
  category,
  seasonal,
}

/// Catalog row from `public.achievements`. Read-only.
class Achievement {
  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.category,
    required this.rarity,
    required this.iconKey,
    required this.conditionType,
    required this.conditionValue,
    required this.rewardXp,
    required this.rewardCoins,
    this.rewardTitleKey,
    required this.isHidden,
    required this.sortOrder,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final AchievementCategoryGroup category;
  final AchievementRarity rarity;
  final String iconKey;
  final String conditionType;
  final num conditionValue;
  final int rewardXp;
  final int rewardCoins;
  final String? rewardTitleKey;
  final bool isHidden;
  final int sortOrder;

  factory Achievement.fromJson(Map<String, dynamic> j) => Achievement(
        id: j['id'] as String,
        titleKey: j['title_key'] as String,
        descriptionKey: j['description_key'] as String,
        category: _cat(j['category'] as String),
        rarity: rarityFromWire(j['rarity'] as String? ?? 'common'),
        iconKey: j['icon_key'] as String? ?? 'star',
        conditionType: j['condition_type'] as String,
        conditionValue: (j['condition_value'] as num?) ?? 0,
        rewardXp: (j['reward_xp'] as num?)?.toInt() ?? 0,
        rewardCoins: (j['reward_coins'] as num?)?.toInt() ?? 0,
        rewardTitleKey: j['reward_title_key'] as String?,
        isHidden: j['is_hidden'] as bool? ?? false,
        sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      );

  static AchievementCategoryGroup _cat(String s) => switch (s) {
        'streak' => AchievementCategoryGroup.streak,
        'level' => AchievementCategoryGroup.level,
        'task' => AchievementCategoryGroup.task,
        'habit' => AchievementCategoryGroup.habit,
        'goal' => AchievementCategoryGroup.goal,
        'social' => AchievementCategoryGroup.social,
        'challenge' => AchievementCategoryGroup.challenge,
        'category' => AchievementCategoryGroup.category,
        _ => AchievementCategoryGroup.seasonal,
      };
}

/// Shared helper used by both Achievement and UnlockedAchievement.
AchievementRarity rarityFromWire(String s) => switch (s) {
      'rare' => AchievementRarity.rare,
      'epic' => AchievementRarity.epic,
      'legendary' => AchievementRarity.legendary,
      _ => AchievementRarity.common,
    };
