import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../goals/application/goal_creation_notifier.dart';

/// Экспорт мечты в другие сущности приложения.
///
/// Мечта надумана — она уходит в цель (там декомпозируется на этапы) или в
/// челлендж. Оба ведут в ШТАТНЫЕ флоу с предзаполненным названием, а не
/// создают сущность молча: цель должна пройти AI-декомпозицию, челлендж —
/// получить метрику и срок. Так экспорт остаётся честным и не дублирует
/// чужую логику.
class DreamExport {
  const DreamExport._();

  /// В цель: засеваем название и уводим в тот же флоу, что и кнопка
  /// «создать цель», — сразу на выбор архетипа, минуя пустое поле ввода.
  ///
  /// [dreamId] передаём, чтобы после создания цели закрепить связь
  /// converted_goal_id — её ставит подписчик в DreamsNotifier.
  static void toGoal(
    BuildContext context,
    WidgetRef ref,
    String title, {
    required String dreamId,
  }) {
    ref
        .read(goalCreationProvider.notifier)
        .startArchetypePick(title: title, sourceDreamId: dreamId);
    context.push('/goals/archetype');
  }

  /// В челлендж: открываем форму создания челленджа с предзаполненным
  /// названием (метрику и срок пользователь задаёт сам).
  static void toChallenge(BuildContext context, String title) {
    context.push('/challenges/new', extra: title);
  }
}
