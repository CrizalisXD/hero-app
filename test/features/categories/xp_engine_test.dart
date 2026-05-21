import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/categories/application/xp_engine.dart';
import 'package:hero/features/categories/data/categories_assets_repository.dart';
import 'package:hero/features/categories/domain/models/xp_inputs.dart';

void main() {
  late XpEngine engine;

  setUpAll(() async {
    final raw = await File('assets/data/categories.json').readAsString();
    final bundle = CategoriesAssetsRepository()
        .parse(jsonDecode(raw) as Map<String, dynamic>);
    engine = XpEngine(bundle);
  });

  group('XpEngine.categoryXp', () {
    test('easy/short/normal: 20 × 0.75 × 0.8 × 1.0 = 12', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.easy,
          duration: TaskDuration.short,
          importance: TaskImportance.normal,
        ),
        12,
      );
    });

    test('normal/medium/normal = 20', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.normal,
          duration: TaskDuration.medium,
          importance: TaskImportance.normal,
        ),
        20,
      );
    });

    test('hard/long/high: 20 × 1.35 × 1.25 × 1.25 ≈ 42', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.hard,
          duration: TaskDuration.long,
          importance: TaskImportance.high,
        ),
        42,
      );
    });

    test('epic/long/high: 20 × 2.0 × 1.25 × 1.25 = 62.5 → 63', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.epic,
          duration: TaskDuration.long,
          importance: TaskImportance.high,
        ),
        anyOf(62, 63),
      );
    });

    test('easy/medium/low: 20 × 0.75 × 1.0 × 0.8 = 12', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.easy,
          duration: TaskDuration.medium,
          importance: TaskImportance.low,
        ),
        12,
      );
    });

    test('normal/long/high: 20 × 1.0 × 1.25 × 1.25 = 31.25 → 31', () {
      expect(
        engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.normal,
          duration: TaskDuration.long,
          importance: TaskImportance.high,
        ),
        31,
      );
    });
  });

  group('XpEngine.discipline', () {
    test('task recurring = 3', () {
      expect(engine.disciplineXpForTask(isRecurring: true), 3);
    });
    test('task one-shot = 0', () {
      expect(engine.disciplineXpForTask(isRecurring: false), 0);
    });
    test('habit = 4', () {
      expect(engine.disciplineXpForHabit(), 4);
    });
  });
}
