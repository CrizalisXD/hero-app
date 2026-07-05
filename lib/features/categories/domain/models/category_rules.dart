import 'category_id.dart';

class CategoryRulesBundle {
  const CategoryRulesBundle({
    required this.version,
    required this.defaultBaseXp,
    required this.categories,
    required this.multipliers,
    required this.classifier,
    required this.metaStats,
  });

  final int version;
  final int defaultBaseXp;
  final List<CategoryRules> categories;
  final XpMultipliers multipliers;
  final ClassifierConfig classifier;
  final MetaStatsRules metaStats;

  CategoryRules? rulesFor(CategoryId id) {
    for (final r in categories) {
      if (r.id == id) return r;
    }
    return null;
  }
}

class CategoryRules {
  const CategoryRules({
    required this.id,
    required this.color,
    required this.icon,
    required this.keywordsRu,
    required this.keywordsEn,
    required this.excludeRu,
    required this.excludeEn,
  });

  // [D4, XP_SYSTEM_TZ §3] base_xp здесь больше нет: источник истины —
  // таблица `categories` в БД (categoryBaseXpProvider); JSON хранит
  // только правила классификатора и клиентские множители превью.
  final CategoryId id;
  final String color;
  final String icon;
  final Map<String, int> keywordsRu;
  final Map<String, int> keywordsEn;
  final List<String> excludeRu;
  final List<String> excludeEn;
}

class XpMultipliers {
  const XpMultipliers({
    required this.difficulty,
    required this.duration,
    required this.importance,
  });

  final Map<String, double> difficulty;
  final Map<String, double> duration;
  final Map<String, double> importance;
}

class ClassifierConfig {
  const ClassifierConfig({
    required this.thresholdMain,
    required this.thresholdSecondaryRatio,
    required this.lowConfidenceThreshold,
    required this.aiFallbackWhenBelow,
  });

  final double thresholdMain;
  final double thresholdSecondaryRatio;
  final int lowConfidenceThreshold;
  final bool aiFallbackWhenBelow;
}

class MetaStatsRules {
  const MetaStatsRules({
    required this.disciplineXp,
  });

  // [D3, XP_SYSTEM_TZ §7] streak_rewards удалены: канон наград за стрик —
  // ачивки streak_3/5/7/21 (XP + коины на сервере).
  final Map<String, int> disciplineXp;
}
