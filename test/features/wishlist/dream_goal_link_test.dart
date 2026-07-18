import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hero/features/goals/application/goal_creation_notifier.dart';

void main() {
  group('связь мечта → цель через sourceDreamId', () {
    test('экспорт из мечты запоминает её id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final n = container.read(goalCreationProvider.notifier);

      n.startArchetypePick(title: 'Прыгнуть с парашютом', sourceDreamId: 'd1');
      expect(n.sourceDreamId, 'd1');
    });

    test('обычное создание цели обнуляет источник — чужая мечта не привяжется',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final n = container.read(goalCreationProvider.notifier);

      n.startArchetypePick(title: 'Мечта', sourceDreamId: 'd1');
      expect(n.sourceDreamId, 'd1');

      // Следующая цель заводится обычной кнопкой, без мечты.
      n.startArchetypePick(title: 'Просто цель');
      expect(n.sourceDreamId, isNull);
    });

    test('reset очищает источник', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final n = container.read(goalCreationProvider.notifier);

      n.startArchetypePick(title: 'Мечта', sourceDreamId: 'd1');
      n.reset();
      expect(n.sourceDreamId, isNull);
    });
  });
}
