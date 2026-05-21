import '../domain/models/category_id.dart';
import '../domain/models/category_rules.dart';
import '../domain/models/classification_result.dart';

/// Local keyword-based classifier. Deterministic, no network.
class CategoryClassifier {
  CategoryClassifier(this._bundle);
  final CategoryRulesBundle _bundle;

  /// Returns a result, or null when confidence is below threshold
  /// (caller should attempt AI fallback).
  ClassificationResult? classify({
    required String text,
    String locale = 'ru',
  }) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) return null;

    final scores = <CategoryId, int>{};
    for (final cat in _bundle.categories) {
      final keywords = locale == 'en' ? cat.keywordsEn : cat.keywordsRu;
      final excludes = locale == 'en' ? cat.excludeEn : cat.excludeRu;

      var score = 0;
      for (final entry in keywords.entries) {
        if (_containsStem(normalized, entry.key)) {
          score += entry.value;
        }
      }
      for (final ex in excludes) {
        if (_containsStem(normalized, ex)) {
          score -= 10;
        }
      }
      if (score > 0) scores[cat.id] = score;
    }

    if (scores.isEmpty) return null;

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final topScore = top.value;

    if (topScore < _bundle.classifier.lowConfidenceThreshold) return null;

    final secondaryThreshold =
        (topScore * _bundle.classifier.thresholdSecondaryRatio).round();
    final secondaries = sorted
        .skip(1)
        .where((e) => e.value >= secondaryThreshold && e.value > 0)
        .take(2)
        .map((e) => e.key)
        .toList();

    final remaining =
        sorted.skip(1).fold<int>(0, (s, e) => s + e.value);
    final double confidence =
        topScore / (topScore + remaining).clamp(1, 1000000);

    return ClassificationResult(
      mainCategory: top.key,
      secondaryCategories: secondaries,
      confidence: confidence,
      source: ClassificationSource.local,
    );
  }

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zа-яё0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Normalise the stem too so hyphenated keywords like "pull-up" → "pull up"
  // match normalised text like "pull ups".
  bool _containsStem(String text, String stem) {
    if (stem.isEmpty) return false;
    final normalizedStem = _normalize(stem);
    return normalizedStem.isNotEmpty && text.contains(normalizedStem);
  }
}
