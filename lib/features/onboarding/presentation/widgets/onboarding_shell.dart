import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    required this.content,
    required this.onContinue,
    this.continueLabel,
    this.continueEnabled = true,
    this.isLoading = false,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final String title;
  final String? subtitle;
  final Widget content;
  final VoidCallback onContinue;
  final String? continueLabel;
  final bool continueEnabled;
  final bool isLoading;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final progress = step / totalSteps;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (onBack != null) ...[
                    GestureDetector(
                      onTap: onBack,
                      child: const Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.bgElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$step/$totalSteps',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: content,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: HeroButton(
                label: continueLabel ?? l.onboardingContinue,
                isLoading: isLoading,
                onPressed: continueEnabled ? onContinue : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
