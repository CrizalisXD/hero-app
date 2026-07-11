import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 4: препятствия СТАРТА (ось «почему трудно начать») — мультивыбор:
/// препятствия редко ходят поодиночке. «Нет мотивации» уехало в экран
/// срывов — здесь его заменил «Не знаю, с чего начать».
class MainObstacleScreen extends ConsumerStatefulWidget {
  const MainObstacleScreen({super.key});

  @override
  ConsumerState<MainObstacleScreen> createState() =>
      _MainObstacleScreenState();
}

class _MainObstacleScreenState extends ConsumerState<MainObstacleScreen> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(ref.read(onboardingControllerProvider).mainObstacles);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: 'no_discipline',
        label: l.onboardingObstacleNoDisc,
        icon: Icons.hourglass_disabled,
      ),
      CardGridOption(
        key: 'no_time',
        label: l.onboardingObstacleNoTime,
        icon: Icons.schedule,
      ),
      CardGridOption(
        key: 'no_start',
        label: l.onboardingObstacleNoStart,
        icon: Icons.help_outline,
      ),
      CardGridOption(
        key: 'no_energy',
        label: l.onboardingObstacleNoEnergy,
        icon: Icons.battery_2_bar,
      ),
      CardGridOption(
        key: 'no_plan',
        label: l.onboardingObstacleNoPlan,
        icon: Icons.alt_route,
      ),
      CardGridOption(
        key: 'fear_failure',
        label: l.onboardingObstacleFear,
        icon: Icons.sentiment_very_dissatisfied,
      ),
    ];

    return OnboardingShell(
      step: 4,
      totalSteps: 12,
      title: l.onboardingObstacleTitle,
      subtitle: l.onboardingObstacleSubtitle,
      onBack: () => context.go('/onboarding/insight'),
      continueEnabled: _selected.isNotEmpty,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setMainObstacles(_selected.toList());
        context.go('/onboarding/failure-reason');
      },
      content: SelectableCardGrid(
        options: options,
        selected: _selected,
        multiSelect: true,
        aspectRatio: 1.25,
        onToggle: (key) => setState(() {
          if (_selected.contains(key)) {
            _selected.remove(key);
          } else {
            _selected.add(key);
          }
        }),
      ),
    );
  }
}
