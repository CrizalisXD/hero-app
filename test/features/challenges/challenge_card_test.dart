import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero/features/challenges/domain/models/challenge_metric_type.dart';
import 'package:hero/features/challenges/domain/models/challenge_participant.dart';
import 'package:hero/features/challenges/presentation/widgets/challenge_card.dart';
import 'package:hero/l10n/generated/app_localizations.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

ChallengeParticipant _participant({
  double progress = 0.65,
  ChallengeStatus status = ChallengeStatus.joined,
  String? titleKey = 'challengeMonthlyStepsTitle',
  String? titleCustom,
}) =>
    ChallengeParticipant(
      participantId: 'p1',
      challengeId: 'c1',
      metricType: ChallengeMetricType.distance,
      titleKey: titleKey,
      titleCustom: titleCustom,
      targetValue: 100,
      progressValue: 100 * progress,
      status: status,
      rewardXp: 100,
      endAt: DateTime.now().add(const Duration(days: 12)),
      joinedAt: DateTime.now(),
    );

void main() {
  testWidgets('карточка участника: рендерится без краша, показывает % и XP',
      (t) async {
    await t.pumpWidget(_wrap(
      ChallengeCard.participant(_participant(), onTap: () {}),
    ));
    expect(t.takeException(), isNull);
    expect(find.text('65%'), findsOneWidget);
    expect(find.textContaining('XP'), findsOneWidget);
    // Кольцо прогресса присутствует для активного своего челленджа.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('завершённый челлендж: бейдж вместо процента, кольца нет',
      (t) async {
    await t.pumpWidget(_wrap(
      ChallengeCard.participant(
        _participant(status: ChallengeStatus.completed),
        onTap: () {},
      ),
    ));
    expect(t.takeException(), isNull);
    // Завершённый не показывает живой процент и кольцо.
    expect(find.text('65%'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('пользовательский челлендж: показывает свой текст, не падает',
      (t) async {
    // Регрессия: user-челленджи имеют title_custom и пустой title_key —
    // раньше это роняло всю вкладку «Мои».
    await t.pumpWidget(_wrap(
      ChallengeCard.participant(
        _participant(titleKey: null, titleCustom: 'Мой личный вызов'),
        onTap: () {},
      ),
    ));
    expect(t.takeException(), isNull);
    expect(find.text('Мой личный вызов'), findsOneWidget);
  });

  testWidgets('тап по карточке срабатывает', (t) async {
    var tapped = false;
    await t.pumpWidget(_wrap(
      ChallengeCard.participant(_participant(), onTap: () => tapped = true),
    ));
    await t.tap(find.byType(ChallengeCard));
    expect(tapped, isTrue);
  });
}
