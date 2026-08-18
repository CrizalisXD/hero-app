import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';
import 'widgets/selectable_card_grid.dart';

/// Шаг 8: когда удобнее заниматься собой — дефолт для времени
/// напоминаний привычек.
class PreferredTimeScreen extends ConsumerStatefulWidget {
  const PreferredTimeScreen({super.key});

  @override
  ConsumerState<PreferredTimeScreen> createState() =>
      _PreferredTimeScreenState();
}

class _PreferredTimeScreenState extends ConsumerState<PreferredTimeScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(onboardingControllerProvider).preferredTime;
    if (existing.isNotEmpty) _selected = existing;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final options = [
      CardGridOption(
        key: 'morning',
        label: l.onboardingPreferredMorning,
        icon: Icons.wb_twilight,
        description: l.onboardingPreferredMorningDesc,
        tint: AppColors.social,
      ),
      CardGridOption(
        key: 'afternoon',
        label: l.onboardingPreferredAfternoon,
        icon: Icons.wb_sunny,
        description: l.onboardingPreferredAfternoonDesc,
        tint: AppColors.finance,
      ),
      CardGridOption(
        key: 'evening',
        label: l.onboardingPreferredEvening,
        icon: Icons.nights_stay,
        description: l.onboardingPreferredEveningDesc,
        tint: AppColors.mind,
      ),
    ];

    return OnboardingShell(
      step: 8,
      totalSteps: 14,
      title: l.onboardingPreferredTitle,
      subtitle: l.onboardingPreferredSubtitle,
      onBack: () => context.go('/onboarding/time-commitment'),
      continueEnabled: _selected != null,
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setPreferredTime(_selected!);
        context.go('/onboarding/support-style');
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
