import '../../../categories/domain/models/category_id.dart';

/// Per-category XP and level for the profile screen.
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.xpTotal,
    required this.level,
  });
  final CategoryId category;
  final int xpTotal;
  final int level;

  factory CategoryProgress.fromJson(Map<String, dynamic> j) {
    return CategoryProgress(
      category:
          CategoryId.fromWire(j['category'] as String?) ?? CategoryId.mind,
      xpTotal: (j['xp_total'] as num?)?.toInt() ?? 0,
      level: (j['level'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Aggregated stats from public.meta_stats.
class MetaStats {
  const MetaStats({
    required this.disciplineXp,
    required this.consistencyScore,
    required this.focusScore,
    required this.currentStreak,
    required this.bestStreak,
    required this.coins,
  });
  final int disciplineXp;
  final int consistencyScore;
  final int focusScore;
  final int currentStreak;
  final int bestStreak;
  final int coins;

  factory MetaStats.fromJson(Map<String, dynamic> j) => MetaStats(
        disciplineXp: (j['discipline_xp'] as num?)?.toInt() ?? 0,
        consistencyScore: (j['consistency_score'] as num?)?.toInt() ?? 0,
        focusScore: (j['focus_score'] as num?)?.toInt() ?? 0,
        currentStreak: (j['current_streak'] as num?)?.toInt() ?? 0,
        bestStreak: (j['best_streak'] as num?)?.toInt() ?? 0,
        coins: (j['coins'] as num?)?.toInt() ?? 0,
      );
}

/// Snapshot of everything the Profile screen needs in one bundle.
class ProfileOverview {
  const ProfileOverview({
    required this.displayName,
    required this.username,
    required this.email,
    required this.level,
    required this.xpCurrent,
    required this.xpToNext,
    required this.xpTotal,
    required this.energy,
    required this.energyMax,
    required this.avatarPrimaryColor,
    required this.categories,
    required this.metaStats,
  });

  final String displayName;

  /// Public @handle from user_public_profiles. Null only if the public
  /// profile row hasn't been created yet.
  final String? username;
  final String? email;
  final int level;
  final int xpCurrent;
  final int xpToNext;
  final int xpTotal;
  final int energy;
  final int energyMax;
  final String avatarPrimaryColor;
  final List<CategoryProgress> categories;
  final MetaStats metaStats;
}
