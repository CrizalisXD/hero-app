import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 10: стартовые привычки — ДИНАМИЧЕСКИЙ каталог: сначала привычки
/// выбранных направлений, добитый универсальными до 4+ вариантов.
/// Ключи должны совпадать со словарём STARTER_HABITS в edge-функции
/// onboarding-bootstrap.
class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(ref.read(onboardingControllerProvider).starterHabits);
  }

  List<CardGridOption> _catalog(BuildContext context) {
    final l = context.l10n;
    final byArea = <String, CardGridOption>{
      'health': CardGridOption(
        key: 'drink_water',
        label: l.onboardingHabitDrinkWater,
        icon: Icons.water_drop,
        tint: AppColors.health,
      ),
      'mind': CardGridOption(
        key: 'read_10_pages',
        label: l.onboardingHabitRead10,
        icon: Icons.menu_book,
        tint: AppColors.mind,
      ),
      'endurance': CardGridOption(
        key: 'walk_10_min',
        label: l.onboardingHabitWalk10,
        icon: Icons.directions_walk,
        tint: AppColors.endurance,
      ),
      'strength': CardGridOption(
        key: 'morning_stretch',
        label: l.onboardingHabitStretch,
        icon: Icons.accessibility_new,
        tint: AppColors.strength,
      ),
      'finance': CardGridOption(
        key: 'track_expenses',
        label: l.onboardingHabitExpenses,
        icon: Icons.receipt_long,
        tint: AppColors.finance,
      ),
      'social': CardGridOption(
        key: 'call_close_person',
        label: l.onboardingHabitCall,
        icon: Icons.call,
        tint: AppColors.social,
      ),
      'creativity': CardGridOption(
        key: 'sketch_10_min',
        label: l.onboardingHabitSketch,
        icon: Icons.brush,
        tint: AppColors.creativity,
      ),
    };

    final areas = ref.read(onboardingControllerProvider).lifeChangeAreas;
    final result = <CardGridOption>[
      for (final a in areas)
        if (byArea.containsKey(a)) byArea[a]!,
    ];
    // Добиваем универсальными, чтобы выбор не был вырожденным.
    for (final fallback in ['health', 'endurance', 'mind']) {
      if (result.length >= 4) break;
      final opt = byArea[fallback]!;
      if (!result.any((o) => o.key == opt.key)) result.add(opt);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = _catalog(context);

    return OnboardingShell(
      step: 10,
      totalSteps: 14,
      title: l.onboardingHabitsTitle,
      subtitle: l.onboardingHabitsSubtitleV2,
      onBack: () => context.go('/onboarding/support-style'),
      continueEnabled: _selected.isNotEmpty,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setStarterHabits(_selected.toList());
        context.go('/onboarding/notifications');
      },
      content: SelectableCardGrid(
        options: options,
        selected: _selected,
        multiSelect: true,
        maxSelect: 3,
        aspectRatio: 1.15,
        onToggle: (key) => setState(() {
          if (_selected.contains(key)) {
            _selected.remove(key);
          } else if (_selected.length < 3) {
            _selected.add(key);
          }
        }),
      ),
    );
  }
}
