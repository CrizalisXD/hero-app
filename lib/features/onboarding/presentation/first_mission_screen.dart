import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

/// Шаг 12: финал — «Твой Герой готов» (слит с бывшим avatar-intro).
/// Медальон-аватар, персональное обращение, submit onboarding-bootstrap.
class FirstMissionScreen extends ConsumerStatefulWidget {
  const FirstMissionScreen({super.key});

  @override
  ConsumerState<FirstMissionScreen> createState() => _FirstMissionScreenState();
}

class _FirstMissionScreenState extends ConsumerState<FirstMissionScreen> {
  bool _loading = false;

  Future<void> _submit() async {
    if (_loading) return;
    // Минимальная защита от пустого черновика (дип-линк мимо шагов).
    final draft = ref.read(onboardingControllerProvider);
    if (draft.lifeChangeAreas.isEmpty || draft.supportStyle.isEmpty) {
      context.go('/onboarding/name');
      return;
    }
    setState(() => _loading = true);

    final ok = await ref.read(onboardingBootstrapProvider.notifier).submit();

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
    final name = ref.watch(onboardingControllerProvider).displayName;

    return OnboardingShell(
      step: 12,
      totalSteps: 12,
      title: name.isEmpty
          ? l.onboardingFirstMissionTitle
          : l.onboardingFirstMissionTitleNamed(name),
      continueLabel: l.onboardingFirstMissionCta,
      isLoading: _loading,
      onBack: () => context.go('/onboarding/notifications'),
      onContinue: _submit,
      scrollable: false,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Медальон героя: градиентное кольцо + свечение (аватар оживёт
          // на Home — здесь его «икона призыва»).
          Container(
            width: 168,
            height: 168,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.5),
                  blurRadius: 60,
                  spreadRadius: -6,
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgElevated,
              ),
              child: const Icon(
                Icons.person,
                size: 84,
                color: AppColors.accentBright,
              ),
            ),
          ),
          const SizedBox(height: 36),
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
