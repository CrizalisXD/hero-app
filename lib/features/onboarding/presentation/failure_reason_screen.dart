import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 5: срывы (ось «почему бросаю начатое»).
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
    _selected.addAll(ref.read(onboardingControllerProvider).failureReasons);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: 'lose_motivation',
        label: l.onboardingFailureLoseMotiv,
        icon: Icons.local_fire_department_outlined,
      ),
      CardGridOption(
        key: 'get_busy',
        label: l.onboardingFailureBusy,
        icon: Icons.work_history,
      ),
      CardGridOption(
        key: 'forget',
        label: l.onboardingFailureForget,
        icon: Icons.notifications_off,
      ),
      CardGridOption(
        key: 'too_hard',
        label: l.onboardingFailureTooHard,
        icon: Icons.trending_down,
      ),
      CardGridOption(
        key: 'no_support',
        label: l.onboardingFailureNoSupport,
        icon: Icons.person_off,
      ),
      CardGridOption(
        key: 'other',
        label: l.onboardingFailureOther,
        icon: Icons.more_horiz,
      ),
    ];

    return OnboardingShell(
      step: 5,
      totalSteps: 12,
      title: l.onboardingFailureTitle,
      subtitle: l.onboardingFailureSubtitle,
      onBack: () => context.go('/onboarding/main-obstacle'),
      continueEnabled: _selected.isNotEmpty,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setFailureReasons(_selected.toList());
        context.go('/onboarding/energy-level');
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
