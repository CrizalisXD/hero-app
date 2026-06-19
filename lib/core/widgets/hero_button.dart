import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Visual variants for [HeroButton].
enum HeroButtonVariant {
  /// Accent gradient fill + glow. The single primary action of a view.
  primary,

  /// Outlined, transparent fill. Secondary actions.
  secondary,

  /// Text-only, no border. Tertiary / inline actions.
  ghost,

  /// Solid error fill for destructive actions.
  danger,
}

/// Button sizes. Heights keep a >=44px touch target for [md]/[lg].
enum HeroButtonSize { sm, md, lg }

/// The single button primitive of the Hero design system.
///
/// Replaces ad-hoc ElevatedButton/OutlinedButton/FilledButton/TextButton usage
/// so every action shares the same shape, motion and accent treatment.
class HeroButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final HeroButtonVariant variant;
  final HeroButtonSize size;

  /// Stretch to the full available width (matches the legacy theme behaviour).
  /// Only honoured when the incoming width constraint is bounded.
  final bool fullWidth;

  const HeroButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = HeroButtonVariant.primary,
    this.size = HeroButtonSize.lg,
    this.fullWidth = true,
  });

  double get _height => switch (size) {
        HeroButtonSize.sm => 40,
        HeroButtonSize.md => 44,
        HeroButtonSize.lg => 48,
      };

  double get _fontSize => switch (size) {
        HeroButtonSize.sm => 13,
        HeroButtonSize.md => 14,
        HeroButtonSize.lg => 15,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = !isLoading && onPressed != null;
    final radius = BorderRadius.circular(AppRadius.m);

    final bool filled = variant == HeroButtonVariant.primary ||
        variant == HeroButtonVariant.danger;
    final Color contentColor = switch (variant) {
      HeroButtonVariant.primary => Colors.white,
      HeroButtonVariant.danger => Colors.white,
      HeroButtonVariant.secondary => AppColors.textSecondary,
      HeroButtonVariant.ghost => AppColors.accent,
    };

    final Gradient? gradient =
        variant == HeroButtonVariant.primary ? AppColors.accentGradient : null;
    final Color? solidColor =
        variant == HeroButtonVariant.danger ? AppColors.error : null;
    final Border? border = variant == HeroButtonVariant.secondary
        ? Border.all(color: AppColors.border)
        : null;

    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: contentColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: contentColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    color: contentColor,
                  ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          color: solidColor,
          borderRadius: radius,
          border: border,
          boxShadow: filled && enabled
              ? [
                  BoxShadow(
                    color: (solidColor ?? AppColors.accent)
                        .withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Only stretch when the parent actually bounds our width.
                // In an unbounded context (e.g. a Row without Expanded)
                // double.infinity would throw, so we shrink-wrap instead.
                final stretch = fullWidth && constraints.maxWidth.isFinite;
                return SizedBox(
                  height: _height,
                  width: stretch ? double.infinity : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(
                      widthFactor: stretch ? null : 1.0,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
