import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';

/// Онбординг-обёртка v2 — визуальный язык мокапа:
/// тёмно-синий градиент с едва заметной сеткой, сегментированный прогресс
/// с бейджем «N/12», caps-лейбл «ШАГ N», крупный заголовок, градиентный CTA.
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
    this.secondaryLabel,
    this.onSecondary,
    this.scrollable = true,
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

  /// Необязательная вторичная кнопка под CTA («Позже», «Пропустить»).
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// false — контент сам управляет прокруткой/растяжением (слайдеры,
  /// центрированные интерстишлы).
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _OnboardingBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      if (onBack != null) ...[
                        _BackButton(onTap: onBack!),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: _SegmentedProgress(
                          step: step,
                          totalSteps: totalSteps,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _StepBadge(step: step, totalSteps: totalSteps),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.onboardingStepLabel(step).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: content,
                        )
                      : Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: content,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeroButton(
                        label: continueLabel ?? l.onboardingContinue,
                        isLoading: isLoading,
                        onPressed: continueEnabled ? onContinue : null,
                      ),
                      if (secondaryLabel != null) ...[
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: onSecondary,
                          child: Text(
                            secondaryLabel!,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
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

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.step, required this.totalSteps});
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgElevated.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        '$step/$totalSteps',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Пунктирная сегментированная полоса прогресса (по сегменту на шаг).
class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.step, required this.totalSteps});
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: Row(
        children: [
          for (var i = 1; i <= totalSteps; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i <= step
                      ? AppColors.accent
                      : AppColors.bgElevated,
                ),
              ),
            ),
            if (i != totalSteps) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

/// Фон мокапа: глубокий сине-фиолетовый градиент + едва заметная сетка.
class _OnboardingBackground extends StatelessWidget {
  const _OnboardingBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF121226), Color(0xFF0D0D14), Color(0xFF0A0A10)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter(), size: Size.infinite),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const cell = 44.0;
    for (var x = 0.0; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
