import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/category_id.dart';
import '../domain/models/category_rules.dart';

class CategoriesAssetsRepository {
  CategoriesAssetsRepository();

  CategoryRulesBundle? _cached;

  Future<CategoryRulesBundle> load() async {
    if (_cached != null) return _cached!;
    final raw = await rootBundle.loadString('assets/data/categories.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cached = parse(json);
    return _cached!;
  }

  // Public so unit tests can parse the JSON directly from dart:io.
  CategoryRulesBundle parse(Map<String, dynamic> j) {
    final cats = (j['categories'] as List<dynamic>).map((c) {
      final m = c as Map<String, dynamic>;
      final keywords = (m['keywords'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
      final excludes = (m['exclude_keywords'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
      return CategoryRules(
        id: CategoryId.fromWire(m['id'] as String)!,
        color: m['color'] as String,
        icon: m['icon'] as String,
        baseXp: (m['base_xp'] as num).toInt(),
        keywordsRu: _mapStringInt(keywords['ru']),
        keywordsEn: _mapStringInt(keywords['en']),
        excludeRu: _listString(excludes['ru']),
        excludeEn: _listString(excludes['en']),
      );
    }).toList();

    final mult = j['xp_multipliers'] as Map<String, dynamic>;
    final cls = (j['classifier'] as Map<String, dynamic>?) ?? const <String, dynamic>{};
    final meta = (j['meta_stats'] as Map<String, dynamic>?) ?? const <String, dynamic>{};

    return CategoryRulesBundle(
      version: (j['version'] as num).toInt(),
      defaultBaseXp: (j['default_base_xp'] as num).toInt(),
      categories: cats,
      multipliers: XpMultipliers(
        difficulty: _mapStringDouble(mult['difficulty']),
        duration: _mapStringDouble(mult['duration']),
        importance: _mapStringDouble(mult['importance']),
      ),
      classifier: ClassifierConfig(
        thresholdMain: (cls['threshold_main'] as num?)?.toDouble() ?? 1.0,
        thresholdSecondaryRatio:
            (cls['threshold_secondary_ratio'] as num?)?.toDouble() ?? 0.5,
        lowConfidenceThreshold:
            (cls['low_confidence_threshold'] as num?)?.toInt() ?? 3,
        aiFallbackWhenBelow: cls['ai_fallback_when_below'] as bool? ?? true,
      ),
      metaStats: MetaStatsRules(
        disciplineXp: _mapStringInt(meta['discipline_xp']),
        streakRewards: _parseStreaks(meta['streak_rewards']),
      ),
    );
  }

  Map<String, int> _mapStringInt(dynamic v) {
    if (v is! Map) return const <String, int>{};
    return Map<String, int>.fromEntries(
      v.entries.map(
        (e) => MapEntry(e.key.toString(), (e.value as num).toInt()),
      ),
    );
  }

  Map<String, double> _mapStringDouble(dynamic v) {
    if (v is! Map) return const <String, double>{};
    return Map<String, double>.fromEntries(
      v.entries.map(
        (e) => MapEntry(e.key.toString(), (e.value as num).toDouble()),
      ),
    );
  }

  List<String> _listString(dynamic v) {
    if (v is! List) return const <String>[];
    return v.map((e) => e.toString()).toList();
  }

  Map<String, StreakReward> _parseStreaks(dynamic v) {
    if (v is! Map) return const <String, StreakReward>{};
    return Map<String, StreakReward>.fromEntries(
      v.entries.map((e) {
        final m = e.value as Map<dynamic, dynamic>;
        return MapEntry(
          e.key.toString(),
          StreakReward(
            disciplineXp: (m['discipline_xp'] as num?)?.toInt() ?? 0,
            coins: (m['coins'] as num?)?.toInt() ?? 0,
          ),
        );
      }),
    );
  }
}

final categoriesAssetsRepositoryProvider =
    Provider<CategoriesAssetsRepository>(
  (ref) => CategoriesAssetsRepository(),
);

final categoryRulesProvider = FutureProvider<CategoryRulesBundle>((ref) async {
  return ref.read(categoriesAssetsRepositoryProvider).load();
});
