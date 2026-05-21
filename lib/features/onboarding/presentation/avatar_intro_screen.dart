import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import 'widgets/onboarding_shell.dart';

class AvatarIntroScreen extends ConsumerWidget {
  const AvatarIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;

    return OnboardingShell(
      step: 8,
      totalSteps: 9,
      title: l.onboardingAvatarIntroTitle,
      onBack: () => context.go('/onboarding/habits'),
      continueLabel: l.onboardingAvatarIntroNext,
      onContinue: () => context.go('/onboarding/first-mission'),
      content: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l.onboardingAvatarIntroBody,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
