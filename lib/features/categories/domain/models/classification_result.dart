import 'category_id.dart';

class ClassificationResult {
  const ClassificationResult({
    required this.mainCategory,
    required this.secondaryCategories,
    required this.confidence,
    required this.source,
    this.aiReason,
  });

  final CategoryId mainCategory;
  final List<CategoryId> secondaryCategories;

  /// 0..1. Local classifier gives a normalised score; AI provides its own.
  final double confidence;

  final ClassificationSource source;

  /// Optional AI commentary — never shown in UI without translation.
  final String? aiReason;
}

enum ClassificationSource { local, ai, fallback }
