import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class MainObstacleScreen extends ConsumerStatefulWidget {
  const MainObstacleScreen({super.key});

  @override
  ConsumerState<MainObstacleScreen> createState() =>
      _MainObstacleScreenState();
}

class _MainObstacleScreenState extends ConsumerState<MainObstacleScreen> {
  String _selected = '';

  @override
  void initState() {
    super.initState();
    _selected = ref.read(onboardingControllerProvider).mainObstacle;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (key: 'no_discipline', label: l.onboardingObstacleNoDisc),
      (key: 'no_time', label: l.onboardingObstacleNoTime),
      (key: 'no_motivation', label: l.onboardingObstacleNoMotiv),
      (key: 'no_energy', label: l.onboardingObstacleNoEnergy),
      (key: 'no_plan', label: l.onboardingObstacleNoPlan),
      (key: 'fear_failure', label: l.onboardingObstacleFear),
    ];

    return OnboardingShell(
      step: 2,
      totalSteps: 9,
      title: l.onboardingObstacleTitle,
      subtitle: l.onboardingObstacleSubtitle,
      continueEnabled: _selected.isNotEmpty,
      onBack: () => context.go('/onboarding/life-change'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setMainObstacle(_selected);
        context.go('/onboarding/energy-level');
      },
      content: ChoiceChipGrid(
        options: options,
        selected: _selected.isEmpty ? {} : {_selected},
        onToggle: (key) => setState(() => _selected = key),
      ),
    );
  }
}
