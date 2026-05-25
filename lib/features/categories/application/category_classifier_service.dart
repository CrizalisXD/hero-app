import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../data/categories_assets_repository.dart';
import '../domain/models/category_id.dart';
import '../domain/models/category_rules.dart';
import '../domain/models/classification_result.dart';
import '../domain/models/xp_inputs.dart';
import 'category_classifier.dart';

/// Thin abstraction over the `ai-classify-category` Edge Function call.
/// Exists so tests can drop in a fake without mocking the whole SupabaseClient.
abstract class AiCategoryClassifierClient {
  /// Returns the validated JSON body from the Edge Function.
  /// Must throw on any non-2xx, missing-data, or transport error.
  Future<Map<String, dynamic>> classify({
    required String text,
    required String entityType,
    required String locale,
  });
}

class SupabaseAiCategoryClassifierClient implements AiCategoryClassifierClient {
  SupabaseAiCategoryClassifierClient(this._client);
  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> classify({
    required String text,
    required String entityType,
    required String locale,
  }) async {
    final res = await _client.functions.invoke(
      'ai-classify-category',
      body: {
        'text': text,
        'entity_type': entityType,
        'locale': locale,
      },
    );
    if (res.status != 200 || res.data is! Map<String, dynamic>) {
      throw Exception('ai_classify_failed');
    }
    return res.data as Map<String, dynamic>;
  }
}

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
    required this.ai,
  });

  final CategoryRulesBundle bundle;
  final CategoryClassifier local;
  final AiCategoryClassifierClient ai;

  /// Local first. AI only when local returned null (low confidence).
  /// If AI fails or returns garbage → fallback to mind, source=fallback.
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
      final d = await ai.classify(
        text: text,
        entityType: entityType,
        locale: locale,
      );

      final main = CategoryId.fromWire(d['main_category'] as String?);
      if (main == null) return _fallback();

      // Safety net: dedup, drop main if duplicated, drop unknown values, cap at 2.
      final secondary =
          ((d['secondary_categories'] as List<dynamic>?) ?? const <dynamic>[])
              .map((e) => CategoryId.fromWire(e as String?))
              .whereType<CategoryId>()
              .where((e) => e != main)
              .toSet()
              .take(2)
              .toList();

      return EnrichedClassification(
        mainCategory: main,
        secondaryCategories: secondary,
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
  return CategoryClassifierService(
    bundle: bundle,
    local: local,
    ai: SupabaseAiCategoryClassifierClient(cl),
  );
});
