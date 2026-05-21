import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

class EnergyLevelScreen extends ConsumerStatefulWidget {
  const EnergyLevelScreen({super.key});

  @override
  ConsumerState<EnergyLevelScreen> createState() => _EnergyLevelScreenState();
}

class _EnergyLevelScreenState extends ConsumerState<EnergyLevelScreen> {
  int _level = 3;

  @override
  void initState() {
    super.initState();
    _level = ref.read(onboardingControllerProvider).energyLevel;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final labels = [
      l.onboardingEnergyExhausted,
      l.onboardingEnergyTired,
      l.onboardingEnergyNormal,
      l.onboardingEnergyEnergized,
      l.onboardingEnergyCharged,
    ];

    return OnboardingShell(
      step: 3,
      totalSteps: 9,
      title: l.onboardingEnergyTitle,
      subtitle: l.onboardingEnergySubtitle,
      onBack: () => context.go('/onboarding/main-obstacle'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setEnergyLevel(_level);
        context.go('/onboarding/time-commitment');
      },
      content: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            labels[_level - 1],
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: List.generate(5, (i) {
              final n = i + 1;
              final isActive = n <= _level;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _level = n),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 56,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.accentDim : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive ? AppColors.accent : AppColors.border,
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$n',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labels[0],
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Text(
                labels[4],
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
