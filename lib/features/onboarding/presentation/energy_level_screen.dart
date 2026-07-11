import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

/// Шаг 6: уровень энергии — крупный неон-слайдер (референс «183 cm»):
/// большое число в рамке с glow + слайдер 1–5 + живой дескриптор.
class EnergyLevelScreen extends ConsumerStatefulWidget {
  const EnergyLevelScreen({super.key});

  @override
  ConsumerState<EnergyLevelScreen> createState() => _EnergyLevelScreenState();
}

class _EnergyLevelScreenState extends ConsumerState<EnergyLevelScreen> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value =
        ref.read(onboardingControllerProvider).energyLevel.toDouble();
  }

  String _descriptor(BuildContext context, int v) {
    final l = context.l10n;
    return switch (v) {
      1 => l.onboardingEnergyExhausted,
      2 => l.onboardingEnergyTired,
      3 => l.onboardingEnergyNormal,
      4 => l.onboardingEnergyEnergized,
      _ => l.onboardingEnergyCharged,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final level = _value.round();

    return OnboardingShell(
      step: 6,
      totalSteps: 12,
      title: l.onboardingEnergyTitle,
      subtitle: l.onboardingEnergySubtitle,
      onBack: () => context.go('/onboarding/failure-reason'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setEnergyLevel(level);
        context.go('/onboarding/time-commitment');
      },
      scrollable: false,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.25),
                  blurRadius: 30,
                  spreadRadius: -6,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$level',
                      style: const TextStyle(
                        fontSize: 72,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentBright,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '/5',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    _descriptor(context, level),
                    key: ValueKey(level),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.bgElevated,
              thumbColor: AppColors.accentBright,
              overlayColor: AppColors.accent.withValues(alpha: 0.2),
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: _value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _value = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l.onboardingEnergyExhausted,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  l.onboardingEnergyCharged,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
