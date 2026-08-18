import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

/// Шаг 3: эмоциональный интерстишл — «Hero понял». Показывает выбранные
/// направления и что будет построено. Без фейковых цифр: честное превью
/// ценности вместо «нам доверяют 692k».
class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  static const _areaMeta = <String, (IconData, Color)>{
    'strength': (Icons.fitness_center, AppColors.strength),
    'endurance': (Icons.directions_run, AppColors.endurance),
    'mind': (Icons.psychology, AppColors.mind),
    'health': (Icons.favorite, AppColors.health),
    'social': (Icons.people, AppColors.social),
    'finance': (Icons.account_balance_wallet, AppColors.finance),
    'creativity': (Icons.palette, AppColors.creativity),
  };

  String _areaLabel(BuildContext context, String key) {
    final l = context.l10n;
    return switch (key) {
      'strength' => l.onboardingAreaStrength,
      'endurance' => l.onboardingAreaEndurance,
      'mind' => l.onboardingAreaMind,
      'health' => l.onboardingAreaHealth,
      'social' => l.onboardingAreaSocial,
      'finance' => l.onboardingAreaFinance,
      'creativity' => l.onboardingAreaCreativity,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final draft = ref.watch(onboardingControllerProvider);
    final name = draft.displayName;

    return OnboardingShell(
      step: 3,
      totalSteps: 14,
      title: name.isEmpty
          ? l.onboardingInsightTitle
          : l.onboardingInsightTitleNamed(name),
      subtitle: l.onboardingInsightSubtitle,
      onBack: () => context.go('/onboarding/life-change'),
      onContinue: () => context.go('/onboarding/main-obstacle'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final area in draft.lifeChangeAreas)
                if (_areaMeta.containsKey(area))
                  _AreaChip(
                    label: _areaLabel(context, area),
                    icon: _areaMeta[area]!.$1,
                    tint: _areaMeta[area]!.$2,
                  ),
            ],
          ),
          const SizedBox(height: 24),
          _PromiseRow(
            icon: Icons.auto_awesome,
            text: l.onboardingInsightPromise1,
          ),
          _PromiseRow(
            icon: Icons.track_changes,
            text: l.onboardingInsightPromise2,
          ),
          _PromiseRow(
            icon: Icons.trending_up,
            text: l.onboardingInsightPromise3,
          ),
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    required this.label,
    required this.icon,
    required this.tint,
  });

  final String label;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromiseRow extends StatelessWidget {
  const _PromiseRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accent.withValues(alpha: 0.18),
            ),
            child: Icon(icon, size: 18, color: AppColors.accentBright),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
