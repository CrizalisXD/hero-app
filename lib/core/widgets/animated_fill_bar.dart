import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// A horizontal progress track whose fill animates to its target value with an
/// ease-out curve and an optional color glow.
///
/// Single source of truth for every gauge in the app (XP, energy, category
/// stats, goal progress). Motion is disabled automatically when the OS
/// "reduce motion" accessibility setting is on.
class AnimatedFillBar extends StatelessWidget {
  /// Fill ratio, clamped to 0..1.
  final double progress;
  final double height;

  /// Solid fill color. Ignored when [gradient] is provided.
  final Color? color;

  /// Gradient fill. Takes precedence over [color].
  final Gradient? gradient;

  final Color trackColor;
  final double radius;
  final bool glow;

  /// Explicit glow color. Useful when [gradient] is set (then [color] is null).
  final Color? glowColorOverride;
  final Duration duration;

  const AnimatedFillBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.gradient,
    this.trackColor = AppColors.bgElevated,
    this.radius = AppRadius.xs,
    this.glow = true,
    this.glowColorOverride,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final clamped = progress.clamp(0.0, 1.0);
    final glowColor = glowColorOverride ?? color ?? AppColors.accent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        color: trackColor,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: clamped),
          duration: reduceMotion ? Duration.zero : duration,
          curve: Curves.easeOutCubic,
          builder: (context, factor, _) => FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: factor,
            child: Container(
              decoration: BoxDecoration(
                color: gradient == null ? glowColor : null,
                gradient: gradient,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: glow
                    ? [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.45),
                          blurRadius: 6,
                          spreadRadius: -1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
