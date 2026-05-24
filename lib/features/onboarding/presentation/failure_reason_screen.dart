import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import '../domain/models/failure_reason.dart';
import 'widgets/choice_chip_grid.dart';
import 'widgets/onboarding_shell.dart';

class FailureReasonScreen extends ConsumerStatefulWidget {
  const FailureReasonScreen({super.key});

  @override
  ConsumerState<FailureReasonScreen> createState() =>
      _FailureReasonScreenState();
}

class _FailureReasonScreenState extends ConsumerState<FailureReasonScreen> {
  final Set<FailureReason> _selected = {};

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
      (value: FailureReason.loseMotivation, label: l.onboardingFailureLoseMotiv),
      (value: FailureReason.noTime, label: l.onboardingFailureNoTime),
      (value: FailureReason.noStructure, label: l.onboardingFailureNoStructure),
      (value: FailureReason.tooHard, label: l.onboardingFailureTooHard),
      (value: FailureReason.boredom, label: l.onboardingFailureBoredom),
      (value: FailureReason.perfectionism, label: l.onboardingFailurePerfectionism),
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
            .setFailureReasons(_selected);
        context.go('/onboarding/support-style');
      },
      content: ChoiceChipGrid<FailureReason>(
        options: options,
        selected: _selected,
        multiSelect: true,
        onToggle: (reason) => setState(() {
          if (_selected.contains(reason)) {
            _selected.remove(reason);
          } else {
            _selected.add(reason);
          }
        }),
      ),
    );
  }
}
