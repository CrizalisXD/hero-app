import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 9: стиль AI-тренера.
class SupportStyleScreen extends ConsumerStatefulWidget {
  const SupportStyleScreen({super.key});

  @override
  ConsumerState<SupportStyleScreen> createState() =>
      _SupportStyleScreenState();
}

class _SupportStyleScreenState extends ConsumerState<SupportStyleScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingControllerProvider).supportStyle;
    if (existing.isNotEmpty) _selected = existing;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: 'direct',
        label: l.onboardingSupportDirect,
        description: l.onboardingSupportDirectDesc,
        icon: Icons.speed,
      ),
      CardGridOption(
        key: 'gentle',
        label: l.onboardingSupportGentle,
        description: l.onboardingSupportGentleDesc,
        icon: Icons.spa,
      ),
      CardGridOption(
        key: 'humorous',
        label: l.onboardingSupportHumorous,
        description: l.onboardingSupportHumorousDesc,
        icon: Icons.sentiment_very_satisfied,
      ),
      CardGridOption(
        key: 'neutral',
        label: l.onboardingSupportNeutral,
        description: l.onboardingSupportNeutralDesc,
        icon: Icons.analytics_outlined,
      ),
    ];

    return OnboardingShell(
      step: 9,
      totalSteps: 12,
      title: l.onboardingSupportTitle,
      subtitle: l.onboardingSupportSubtitle,
      onBack: () => context.go('/onboarding/preferred-time'),
      continueEnabled: _selected != null,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setSupportStyle(_selected!);
        context.go('/onboarding/habits');
      },
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final o in options)
            SelectableRowCard(
              option: o,
              selected: _selected == o.key,
              onTap: () => setState(() => _selected = o.key),
            ),
        ],
      ),
    );
  }
}
