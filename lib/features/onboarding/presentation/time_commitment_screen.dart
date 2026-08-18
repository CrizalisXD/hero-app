import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 7: время в день.
class TimeCommitmentScreen extends ConsumerStatefulWidget {
  const TimeCommitmentScreen({super.key});

  @override
  ConsumerState<TimeCommitmentScreen> createState() =>
      _TimeCommitmentScreenState();
}

class _TimeCommitmentScreenState extends ConsumerState<TimeCommitmentScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref
        .read(onboardingControllerProvider)
        .timeCommitmentMinutes
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: '5',
        label: l.onboardingTime5min,
        icon: Icons.bolt,
        description: l.onboardingTime5Desc,
      ),
      CardGridOption(
        key: '15',
        label: l.onboardingTime15min,
        icon: Icons.timer_outlined,
        description: l.onboardingTime15Desc,
      ),
      CardGridOption(
        key: '30',
        label: l.onboardingTime30min,
        icon: Icons.hourglass_bottom,
        description: l.onboardingTime30Desc,
      ),
      CardGridOption(
        key: '60',
        label: l.onboardingTime60min,
        icon: Icons.rocket_launch,
        description: l.onboardingTime60Desc,
      ),
    ];

    return OnboardingShell(
      step: 7,
      totalSteps: 14,
      title: l.onboardingTimeTitle,
      subtitle: l.onboardingTimeSubtitle,
      onBack: () => context.go('/onboarding/energy-level'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setTimeCommitment(int.parse(_selected));
        context.go('/onboarding/preferred-time');
      },
      content: SelectableCardGrid(
        options: options,
        selected: {_selected},
        aspectRatio: 1.05,
        onToggle: (key) => setState(() => _selected = key),
      ),
    );
  }
}
