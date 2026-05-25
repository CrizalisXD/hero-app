// Tests for CategoryClassifierService — the facade that routes between
// local classifier and the `ai-classify-category` Edge Function.
//
// Four scenarios per TZ §9.2:
//   1. local known text       → source=local,     AI never called
//   2. unknown + AI success   → source=ai,        AI called once
//   3. unknown + AI failure   → source=fallback,  AI called once, threw
//   4. AI returns "discipline"→ source=fallback   (server already rejects,
//                                                  client double-checks via
//                                                  CategoryId.fromWire = null)
//
// The Edge Function call is mocked via [AiCategoryClassifierClient] —
// the abstraction that exists exactly so this test doesn't have to mock
// SupabaseClient.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/categories/application/category_classifier.dart';
import 'package:hero/features/categories/application/category_classifier_service.dart';
import 'package:hero/features/categories/data/categories_assets_repository.dart';
import 'package:hero/features/categories/domain/models/category_id.dart';
import 'package:hero/features/categories/domain/models/category_rules.dart';
import 'package:hero/features/categories/domain/models/classification_result.dart';

class _FakeAiClient implements AiCategoryClassifierClient {
  _FakeAiClient(this._behavior);

  /// What to do when `classify` is called.
  /// Either return a body, or throw if the function should be considered failed.
  final Future<Map<String, dynamic>> Function() _behavior;

  int callCount = 0;

  @override
  Future<Map<String, dynamic>> classify({
    required String text,
    required String entityType,
    required String locale,
  }) async {
    callCount++;
    return _behavior();
  }
}

Future<CategoryRulesBundle> _loadBundle() async {
  final raw = await File('assets/data/categories.json').readAsString();
  return CategoriesAssetsRepository()
      .parse(jsonDecode(raw) as Map<String, dynamic>);
}

CategoryClassifierService _service({
  required CategoryRulesBundle bundle,
  required AiCategoryClassifierClient ai,
}) {
  return CategoryClassifierService(
    bundle: bundle,
    local: CategoryClassifier(bundle),
    ai: ai,
  );
}

void main() {
  late CategoryRulesBundle bundle;

  setUpAll(() async {
    bundle = await _loadBundle();
  });

  group('CategoryClassifierService', () {
    test('1. local known text — source=local, AI never called', () async {
      final ai = _FakeAiClient(
        () async => throw StateError('AI must not be called for known text'),
      );
      final svc = _service(bundle: bundle, ai: ai);

      final res = await svc.classify(text: 'Пробежать 5 км', locale: 'ru');

      expect(res.source, ClassificationSource.local);
      expect(res.mainCategory, CategoryId.endurance);
      expect(
        ai.callCount,
        0,
        reason: 'AI must not be called when local resolves',
      );
      expect(res.isConfident, isTrue);
    });

    test('2. unknown text + AI success — source=ai', () async {
      final ai = _FakeAiClient(
        () async => <String, dynamic>{
          'main_category': 'health',
          'secondary_categories': <String>['mind'],
          'difficulty': 'normal',
          'duration': 'medium',
          'importance': 'high',
          'discipline_xp_reward': 5,
          'confidence': 0.76,
          'reason': 'lifestyle change',
        },
      );
      final svc = _service(bundle: bundle, ai: ai);

      final res = await svc.classify(
        text: 'хочу перестать быть амёбой и начать нормально жить',
        locale: 'ru',
      );

      expect(res.source, ClassificationSource.ai);
      expect(res.mainCategory, CategoryId.health);
      expect(res.secondaryCategories, [CategoryId.mind]);
      expect(ai.callCount, 1);
      expect(res.isConfident, isTrue);
    });

    test(
      '3. unknown text + AI failure — fallback mind, confidence=0.0',
      () async {
        final ai = _FakeAiClient(
          () async => throw Exception('ai_classify_failed'),
        );
        final svc = _service(bundle: bundle, ai: ai);

        final res = await svc.classify(
          text: 'абракадабра шурум-бурум',
          locale: 'ru',
        );

        expect(res.source, ClassificationSource.fallback);
        expect(res.mainCategory, CategoryId.mind);
        expect(res.confidence, 0.0);
        expect(ai.callCount, 1);
        expect(
          res.isConfident,
          isFalse,
          reason: 'fallback must NOT be shown as a confident chip in UI',
        );
      },
    );

    test('4. AI returns invalid "discipline" — fallback mind', () async {
      final ai = _FakeAiClient(
        () async => <String, dynamic>{
          // Server-side validator should normally reject this with 502;
          // belt-and-suspenders: client also drops anything CategoryId.fromWire
          // cannot parse.
          'main_category': 'discipline',
          'secondary_categories': <String>[],
          'difficulty': 'normal',
          'duration': 'medium',
          'importance': 'normal',
          'discipline_xp_reward': 5,
          'confidence': 0.9,
          'reason': 'should be rejected',
        },
      );
      final svc = _service(bundle: bundle, ai: ai);

      final res = await svc.classify(
        text: 'xyzzy plugh frobnitz',
        locale: 'ru',
      );

      expect(res.source, ClassificationSource.fallback);
      expect(res.mainCategory, CategoryId.mind);
      expect(res.isConfident, isFalse);
    });

    test('drops duplicate-of-main from secondary_categories', () async {
      // AI accidentally returns main inside secondaries — service must dedup.
      final ai = _FakeAiClient(
        () async => <String, dynamic>{
          'main_category': 'health',
          'secondary_categories': <String>[
            'health',
            'mind',
            'mind',
            'endurance',
          ],
          'difficulty': 'normal',
          'duration': 'medium',
          'importance': 'normal',
          'discipline_xp_reward': 0,
          'confidence': 0.5,
          'reason': '',
        },
      );
      final svc = _service(bundle: bundle, ai: ai);

      final res = await svc.classify(
        text: 'xyzzy plugh frobnitz mixed',
        locale: 'ru',
      );

      expect(res.mainCategory, CategoryId.health);
      expect(res.secondaryCategories, [CategoryId.mind, CategoryId.endurance]);
      // Cap at 2, no duplicates, no main.
      expect(res.secondaryCategories.length, lessThanOrEqualTo(2));
      expect(res.secondaryCategories, isNot(contains(CategoryId.health)));
    });
  });
}
