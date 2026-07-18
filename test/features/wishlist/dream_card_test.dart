import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero/features/wishlist/application/dreams_notifier.dart';
import 'package:hero/features/wishlist/domain/dream.dart';
import 'package:hero/features/wishlist/domain/dream_follow.dart';
import 'package:hero/features/wishlist/presentation/widgets/dream_card.dart';
import 'package:hero/l10n/generated/app_localizations.dart';

Dream _dream({
  int wantCount = 5,
  int doneCount = 0,
  double? difficultyAvg,
  double? worthAvg,
}) =>
    Dream(
      id: 'd1',
      title: 'Прыгнуть с парашютом',
      wantCount: wantCount,
      doneCount: doneCount,
      difficultyVotes: difficultyAvg == null ? 0 : 3,
      worthVotes: worthAvg == null ? 0 : 3,
      difficultyAvg: difficultyAvg,
      worthAvg: worthAvg,
      createdAt: DateTime(2026, 1, 1),
    );

DreamFollow _follow() => DreamFollow(
      id: 'f1',
      dreamId: 'd1',
      isPublic: false,
      createdAt: DateTime(2026, 1, 1),
    );

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('показывает три метрики, когда мечту делали', (t) async {
    await t.pumpWidget(_wrap(DreamCardTile(
      card: DreamCard(
          dream: _dream(doneCount: 2, difficultyAvg: 3.2, worthAvg: 4.8)),
      onWant: () {},
      onOpen: () {},
    )));

    expect(find.text('Прыгнуть с парашютом'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // want
    expect(find.text('3.2'), findsOneWidget); // difficulty
    expect(find.text('4.8'), findsOneWidget); // worth
  });

  testWidgets('непройденная мечта показывает «никто не пробовал», а не «0»',
      (t) async {
    await t.pumpWidget(_wrap(DreamCardTile(
      card: DreamCard(dream: _dream(doneCount: 0, worthAvg: null)),
      onWant: () {},
      onOpen: () {},
    )));

    expect(find.text('никто не пробовал'), findsOneWidget);
    expect(find.text('0.0'), findsNothing); // не должно быть фейкового нуля
  });

  testWidgets('большие числа сокращаются (1243 → 1.2k)', (t) async {
    await t.pumpWidget(_wrap(DreamCardTile(
      card: DreamCard(dream: _dream(wantCount: 1243)),
      onWant: () {},
      onOpen: () {},
    )));

    expect(find.text('1.2k'), findsOneWidget);
  });

  testWidgets('тап по сердцу вызывает onWant', (t) async {
    var tapped = false;
    await t.pumpWidget(_wrap(DreamCardTile(
      card: DreamCard(dream: _dream()),
      onWant: () => tapped = true,
      onOpen: () {},
    )));

    await t.tap(find.byIcon(Icons.favorite_border));
    expect(tapped, isTrue);
  });

  test('фильтр «только мои» скрывает чужие мечты', () {
    final state = DreamsState(
      cards: [
        DreamCard(dream: _dream()), // чужая
        DreamCard(dream: _dream(), follow: _follow()), // моя
      ],
    );
    expect(state.visible.length, 2);

    final mine = DreamsState(cards: state.cards, onlyMine: true);
    expect(mine.visible.length, 1);
    expect(mine.visible.single.isMine, isTrue);
  });

  test('снятие «сделал» обнуляет оценку (иначе БД отвергнет)', () {
    final done = DreamFollow(
      id: 'f1',
      dreamId: 'd1',
      isPublic: false,
      doneAt: DateTime(2026, 1, 1),
      worthRating: 5,
      createdAt: DateTime(2026, 1, 1),
    );
    expect(done.canRateWorth, isTrue);

    final undone = done.copyWith(clearDone: true);
    expect(undone.isDone, isFalse);
    expect(undone.worthRating, isNull);
  });
}
