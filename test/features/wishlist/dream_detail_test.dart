import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero/features/wishlist/domain/dream_comment.dart';
import 'package:hero/features/wishlist/domain/dream_doer.dart';
import 'package:hero/features/wishlist/presentation/widgets/dream_comments.dart';
import 'package:hero/features/wishlist/presentation/widgets/dream_doers_list.dart';
import 'package:hero/features/wishlist/presentation/widgets/dream_rating_row.dart';
import 'package:hero/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

DreamComment _comment({int? worth}) => DreamComment(
      id: 'c1',
      dreamId: 'd1',
      userId: 'u1',
      body: 'Берите тандем с видео',
      createdAt: DateTime(2026, 1, 1),
      authorName: 'Марина',
      authorWorthRating: worth,
    );

DreamDoer _doer() => DreamDoer(
      userId: 'u1',
      displayName: 'Марина',
      worthRating: 5,
      note: 'Страшно только до двери',
      doneAt: DateTime(2026, 1, 1),
    );

void main() {
  testWidgets('пустой список сделавших зовёт стать первым, не показывает 0',
      (t) async {
    await t.pumpWidget(_wrap(const DreamDoersList(doers: [])));
    expect(find.text('Пока никто не отметился. Стань первым.'), findsOneWidget);
  });

  testWidgets('сделавший показывается с оценкой и советом', (t) async {
    await t.pumpWidget(_wrap(DreamDoersList(doers: [_doer()])));
    expect(find.text('Марина'), findsOneWidget);
    expect(find.text('Страшно только до двери'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('реплика сделавшего помечена «сделал(а) это»', (t) async {
    await t.pumpWidget(_wrap(DreamComments(
      comments: [_comment(worth: 5)],
      onSubmit: (_) async => true,
    )));
    expect(find.text('сделал(а) это'), findsOneWidget);
  });

  testWidgets('реплика зрителя (без worth) НЕ помечена', (t) async {
    await t.pumpWidget(_wrap(DreamComments(
      comments: [_comment(worth: null)],
      onSubmit: (_) async => true,
    )));
    expect(find.text('сделал(а) это'), findsNothing);
  });

  testWidgets('рейтинг-строка вызывает onRate с номером', (t) async {
    int? rated;
    await t.pumpWidget(_wrap(DreamRatingRow(
      question: 'Сложно?',
      value: null,
      color: Colors.blue,
      onRate: (v) => rated = v,
    )));
    // 5 иконок в ряд; тапаем по третьей.
    await t.tap(find.byType(Icon).at(2));
    expect(rated, 3);
  });

  test('DreamComment.isFromDoer зависит от authorWorthRating', () {
    expect(_comment(worth: 4).isFromDoer, isTrue);
    expect(_comment(worth: null).isFromDoer, isFalse);
  });
}
