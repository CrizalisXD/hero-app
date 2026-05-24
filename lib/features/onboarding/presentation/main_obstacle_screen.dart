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
      (value: 'no_discipline', label: l.onboardingObstacleNoDisc),
      (value: 'no_time', label: l.onboardingObstacleNoTime),
      (value: 'no_motivation', label: l.onboardingObstacleNoMotiv),
      (value: 'no_energy', label: l.onboardingObstacleNoEnergy),
      (value: 'no_plan', label: l.onboardingObstacleNoPlan),
      (value: 'fear_failure', label: l.onboardingObstacleFear),
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
      content: ChoiceChipGrid<String>(
        options: options,
        selected: _selected.isEmpty ? {} : {_selected},
        onToggle: (value) => setState(() => _selected = value),
      ),
    );
  }
}
