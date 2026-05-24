import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class TimeCommitmentScreen extends ConsumerStatefulWidget {
  const TimeCommitmentScreen({super.key});

  @override
  ConsumerState<TimeCommitmentScreen> createState() =>
      _TimeCommitmentScreenState();
}

class _TimeCommitmentScreenState extends ConsumerState<TimeCommitmentScreen> {
  int _minutes = 0;

  @override
  void initState() {
    super.initState();
    _minutes = ref.read(onboardingControllerProvider).timeCommitmentMinutes;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (value: 5, label: l.onboardingTime5min),
      (value: 15, label: l.onboardingTime15min),
      (value: 30, label: l.onboardingTime30min),
      (value: 60, label: l.onboardingTime60min),
    ];

    return OnboardingShell(
      step: 4,
      totalSteps: 9,
      title: l.onboardingTimeTitle,
      subtitle: l.onboardingTimeSubtitle,
      continueEnabled: _minutes > 0,
      onBack: () => context.go('/onboarding/energy-level'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setTimeCommitment(_minutes);
        context.go('/onboarding/failure-reason');
      },
      content: ChoiceChipGrid<int>(
        options: options,
        selected: _minutes > 0 ? {_minutes} : {},
        onToggle: (value) => setState(() => _minutes = value),
      ),
    );
  }
}
