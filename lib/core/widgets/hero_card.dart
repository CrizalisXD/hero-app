import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// The single surface primitive of the Hero design system.
///
/// Solid (no glass/blur) card with press-scale + optional gradient border.
/// Tappable cards animate to 0.97 on press for haptic-feel feedback, matching
/// the gamified RPG identity of Hero.
///
/// Use the default constructor for ordinary content and [HeroCard.hero] for
/// "hero moments" (active goal, unlocked reward, rare challenge) where a glowing
/// gradient border draws the eye.
class HeroCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Gradient? borderGradient;
  final Gradient? backgroundGradient;
  final double radius;

  /// When true, a soft accent glow is drawn behind the card.
  final bool glow;
  final bool haptic;

  const HeroCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.borderColor,
    this.borderGradient,
    this.backgroundGradient,
    this.radius = AppRadius.l,
    this.glow = false,
    this.haptic = true,
  });

  /// Highlighted card with a gradient border + glow for reward / focus moments.
  const HeroCard.hero({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    Gradient gradient = AppColors.accentGradient,
    this.backgroundGradient,
    this.radius = AppRadius.l,
    this.glow = true,
    this.haptic = true,
  })  : borderGradient = gradient,
        borderColor = null;

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null && widget.onLongPress == null) return;
    if (mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final tappable = widget.onTap != null || widget.onLongPress != null;
    final radius = BorderRadius.circular(widget.radius);

    final List<BoxShadow> shadows = _pressed
        ? const []
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
            if (widget.glow)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.30),
                blurRadius: 18,
                spreadRadius: -4,
              ),
          ];

    Widget content = AnimatedContainer(
      duration: Duration(milliseconds: reduceMotion ? 0 : 180),
      curve: Curves.easeOut,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: widget.backgroundGradient == null ? AppColors.bgCard : null,
        gradient: widget.backgroundGradient,
        borderRadius: radius,
        border: widget.borderGradient == null
            ? Border.all(color: widget.borderColor ?? AppColors.border)
            : null,
        boxShadow: widget.borderGradient == null ? shadows : null,
      ),
      child: widget.child,
    );

    if (widget.borderGradient != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: widget.borderGradient,
          boxShadow: shadows,
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              (widget.radius - 1.2).clamp(0, widget.radius),
            ),
            child: content,
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: Duration(milliseconds: reduceMotion ? 0 : 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: tappable ? (_) => _setPressed(true) : null,
        onTapCancel: tappable ? () => _setPressed(false) : null,
        onTapUp: tappable ? (_) => _setPressed(false) : null,
        onTap: widget.onTap == null
            ? null
            : () {
                if (widget.haptic) HapticFeedback.lightImpact();
                widget.onTap!();
              },
        onLongPress: widget.onLongPress,
        child: content,
      ),
    );
  }
}
