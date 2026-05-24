import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class FailureReasonScreen extends ConsumerStatefulWidget {
  const FailureReasonScreen({super.key});

  @override
  ConsumerState<FailureReasonScreen> createState() =>
      _FailureReasonScreenState();
}

class _FailureReasonScreenState extends ConsumerState<FailureReasonScreen> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(
      ref.read(onboardingControllerProvider).failureReasons,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      (key: 'lose_motivation', label: l.onboardingFailureLoseMotiv),
      (key: 'no_time', label: l.onboardingFailureNoTime),
      (key: 'no_structure', label: l.onboardingFailureNoStructure),
      (key: 'too_hard', label: l.onboardingFailureTooHard),
      (key: 'boredom', label: l.onboardingFailureBoredom),
      (key: 'perfectionism', label: l.onboardingFailurePerfectionism),
    ];

    return OnboardingShell(
      step: 5,
      totalSteps: 9,
      title: l.onboardingFailureTitle,
      subtitle: l.onboardingFailureSubtitle,
      continueEnabled: _selected.isNotEmpty,
      onBack: () => context.go('/onboarding/time-commitment'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setFailureReasons(_selected.toList());
        context.go('/onboarding/support-style');
      },
      content: ChoiceChipGrid(
        options: options,
        selected: _selected,
        multiSelect: true,
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
