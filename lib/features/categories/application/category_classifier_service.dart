import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../data/categories_assets_repository.dart';
import '../domain/models/category_id.dart';
import '../domain/models/category_rules.dart';
import '../domain/models/classification_result.dart';
import '../domain/models/xp_inputs.dart';
import 'category_classifier.dart';

/// AI result may include difficulty/duration/importance hints.
/// Local path leaves them null — defaults are applied at task creation.
class EnrichedClassification extends ClassificationResult {
  const EnrichedClassification({
    required super.mainCategory,
    required super.secondaryCategories,
    required super.confidence,
    required super.source,
    super.aiReason,
    this.suggestedDifficulty,
    this.suggestedDuration,
    this.suggestedImportance,
    this.suggestedDisciplineXp,
  });

  final TaskDifficulty? suggestedDifficulty;
  final TaskDuration? suggestedDuration;
  final TaskImportance? suggestedImportance;
  final int? suggestedDisciplineXp;
}

class CategoryClassifierService {
  CategoryClassifierService({
    required this.bundle,
    required this.local,
    required this.client,
  });

  final CategoryRulesBundle bundle;
  final CategoryClassifier local;
  final SupabaseClient client;

  /// Local first. If confidence is below threshold → AI fallback.
  /// If AI fails → fallback to mind.
  Future<EnrichedClassification> classify({
    required String text,
    String entityType = 'task',
    String locale = 'ru',
  }) async {
    final localRes = local.classify(text: text, locale: locale);
    if (localRes != null) {
      return EnrichedClassification(
        mainCategory: localRes.mainCategory,
        secondaryCategories: localRes.secondaryCategories,
        confidence: localRes.confidence,
        source: ClassificationSource.local,
      );
    }

    try {
      final res = await client.functions.invoke(
        'ai-classify-category',
        body: {
          'text': text,
          'entity_type': entityType,
          'locale': locale,
        },
      );

      if (res.status == 200 && res.data is Map<String, dynamic>) {
        final d = res.data as Map<String, dynamic>;
        final main = CategoryId.fromWire(d['main_category'] as String?);
        if (main == null) return _fallback();

        return EnrichedClassification(
          mainCategory: main,
          secondaryCategories: ((d['secondary_categories'] as List<dynamic>?) ??
                  const <dynamic>[])
              .map((e) => CategoryId.fromWire(e as String?))
              .whereType<CategoryId>()
              .toList(),
          confidence: (d['confidence'] as num?)?.toDouble() ?? 0.5,
          source: ClassificationSource.ai,
          aiReason: d['reason'] as String?,
          suggestedDifficulty:
              TaskDifficulty.fromWire(d['difficulty'] as String?),
          suggestedDuration: TaskDuration.fromWire(d['duration'] as String?),
          suggestedImportance:
              TaskImportance.fromWire(d['importance'] as String?),
          suggestedDisciplineXp:
              (d['discipline_xp_reward'] as num?)?.toInt(),
        );
      }
      return _fallback();
    } catch (_) {
      return _fallback();
    }
  }

  EnrichedClassification _fallback() => const EnrichedClassification(
        mainCategory: CategoryId.mind,
        secondaryCategories: [],
        confidence: 0.0,
        source: ClassificationSource.fallback,
      );
}

final categoryClassifierServiceProvider =
    FutureProvider<CategoryClassifierService>((ref) async {
  final bundle = await ref.read(categoryRulesProvider.future);
  final local = CategoryClassifier(bundle);
  final cl = ref.read(supabaseClientProvider);
  return CategoryClassifierService(bundle: bundle, local: local, client: cl);
});
