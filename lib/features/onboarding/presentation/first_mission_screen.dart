import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

class FirstMissionScreen extends ConsumerStatefulWidget {
  const FirstMissionScreen({super.key});

  @override
  ConsumerState<FirstMissionScreen> createState() => _FirstMissionScreenState();
}

class _FirstMissionScreenState extends ConsumerState<FirstMissionScreen> {
  bool _loading = false;

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);

    final ok = await ref
        .read(onboardingBootstrapProvider.notifier)
        .submit();

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.onboardingSaveError),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return OnboardingShell(
      step: 9,
      totalSteps: 9,
      title: l.onboardingFirstMissionTitle,
      continueLabel: l.onboardingFirstMissionCta,
      isLoading: _loading,
      onBack: () => context.go('/onboarding/avatar-intro'),
      onContinue: _submit,
      content: Column(
        children: [
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.accentGradient.createShader(bounds),
            child: const Icon(
              Icons.bolt,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l.onboardingFirstMissionBody,
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
