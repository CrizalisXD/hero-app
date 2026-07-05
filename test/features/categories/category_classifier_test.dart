import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hero/features/categories/application/category_classifier.dart';
import 'package:hero/features/categories/data/categories_assets_repository.dart';
import 'package:hero/features/categories/domain/models/category_id.dart';

Future<CategoryClassifier> _buildClassifier() async {
  final raw = await File('assets/data/categories.json').readAsString();
  final bundle = CategoriesAssetsRepository()
      .parse(jsonDecode(raw) as Map<String, dynamic>);
  return CategoryClassifier(bundle);
}

void main() {
  late CategoryClassifier classifier;

  setUpAll(() async {
    classifier = await _buildClassifier();
  });

  void expectMain(
    String text,
    CategoryId expected, {
    String locale = 'ru',
  }) {
    final res = classifier.classify(text: text, locale: locale);
    expect(res, isNotNull, reason: 'got null for "$text"');
    expect(res!.mainCategory, expected, reason: 'text: "$text"');
  }

  void expectLowConfidence(String text, {String locale = 'ru'}) {
    final res = classifier.classify(text: text, locale: locale);
    expect(
      res,
      isNull,
      reason:
          'expected null (low confidence) for "$text", got ${res?.mainCategory.name}',
    );
  }

  group('RU strength', () {
    test('жим лёжа', () => expectMain('Сделать жим лёжа', CategoryId.strength));
    test('отжимания', () => expectMain('Сделать 30 отжиманий', CategoryId.strength));
    test('подтягивания', () => expectMain('5 подтягиваний', CategoryId.strength));
    test('спортзал + тренировка', () => expectMain('Сходить в спортзал на тренировку', CategoryId.strength));
  });

  group('RU mind', () {
    test('читать книгу', () => expectMain('Прочитать 10 страниц книги', CategoryId.mind));
    test('учить английский', () => expectMain('Учить английские слова', CategoryId.mind));
    test('программирование', () => expectMain('Решить задачу по программированию', CategoryId.mind));
    test('подкаст', () => expectMain('Послушать подкаст про науку', CategoryId.mind));
  });

  group('RU endurance', () {
    test('пробежать 5 км', () => expectMain('Пробежать 5 км', CategoryId.endurance));
    test('марафон', () => expectMain('Готовиться к марафону', CategoryId.endurance));
    test('прогулка', () => expectMain('Прогулка 30 минут вечером', CategoryId.endurance));
    test('10000 шагов', () => expectMain('Пройти 10000 шагов', CategoryId.endurance));
  });

  group('RU health', () {
    test('пить воду', () => expectMain('Пить воду утром', CategoryId.health));
    test('поспать 8 часов', () => expectMain('Поспать 8 часов', CategoryId.health));
    test('к стоматологу', () => expectMain('Сходить к стоматологу', CategoryId.health));
    // [D7] медитация — восстановление психики, не когнитивный вход.
    test('медитация', () => expectMain('Медитация 10 минут', CategoryId.health));
  });

  group('RU social', () {
    test('позвонить маме', () => expectMain('Позвонить маме', CategoryId.social));
    test('встретиться с другом', () => expectMain('Встретиться с другом', CategoryId.social));
    test('свидание', () => expectMain('Сходить на свидание', CategoryId.social));
  });

  group('RU finance', () {
    test('отложить шекели', () => expectMain('Отложить 100 шекелей', CategoryId.finance));
    test('бюджет', () => expectMain('Составить бюджет на месяц', CategoryId.finance));
    test('записать расходы', () => expectMain('Записать расходы', CategoryId.finance));
  });

  group('RU creativity', () {
    test('нарисовать скетч', () => expectMain('Нарисовать скетч', CategoryId.creativity));
    // [D7] создать текст — творческий выход, не обучение.
    test('написать главу книги', () => expectMain('Написать главу книги', CategoryId.creativity));
    test('снять видео YouTube', () => expectMain('Снять видео на YouTube', CategoryId.creativity));
  });

  group('EN', () {
    test('bench press', () => expectMain('Bench press 80 kg', CategoryId.strength, locale: 'en'));
    test('pull-ups', () => expectMain('5 pull-ups', CategoryId.strength, locale: 'en'));
    test('read pages', () => expectMain('Read 20 pages', CategoryId.mind, locale: 'en'));
    test('study english vocabulary', () => expectMain('Study English vocabulary', CategoryId.mind, locale: 'en'));
    test('run 5km', () => expectMain('Run 5km in the park', CategoryId.endurance, locale: 'en'));
    test('train for marathon', () => expectMain('Train for marathon', CategoryId.endurance, locale: 'en'));
    test('drink water', () => expectMain('Drink water in the morning', CategoryId.health, locale: 'en'));
    test('call mom', () => expectMain('Call mom', CategoryId.social, locale: 'en'));
    test('save dollars', () => expectMain('Save 100 dollars', CategoryId.finance, locale: 'en'));
    test('draw a sketch', () => expectMain('Draw a sketch', CategoryId.creativity, locale: 'en'));
  });

  group('exclusions & edge cases', () {
    test('марафон НЕ в strength', () {
      final res = classifier.classify(text: 'Готовиться к марафону');
      expect(res, isNotNull);
      expect(res!.mainCategory, isNot(CategoryId.strength));
    });

    test('low confidence: общее слово', () => expectLowConfidence('Сделать что-нибудь'));

    test('пустая строка → null', () {
      expect(classifier.classify(text: ''), isNull);
      expect(classifier.classify(text: '   '), isNull);
    });

    test('secondaries ≤ 2', () {
      final res = classifier.classify(text: 'Йога с растяжкой 30 минут');
      if (res != null) {
        expect(res.secondaryCategories.length, lessThanOrEqualTo(2));
      }
    });

    test('confidence ∈ [0, 1]', () {
      final res = classifier.classify(text: 'Пробежать 5 км');
      expect(res, isNotNull);
      expect(res!.confidence, greaterThanOrEqualTo(0.0));
      expect(res.confidence, lessThanOrEqualTo(1.0));
    });

    test('source = local', () {
      final res = classifier.classify(text: 'Пить воду утром');
      expect(res, isNotNull);
      expect(res!.source.name, 'local');
    });
  });
}
