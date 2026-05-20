import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';

/// Card with press-scale + optional gradient border.
///
/// Tappable cards animate to 0.97 on press for haptic-feel feedback,
/// matching the gamified RPG identity of Hero.
class HeroCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? borderColor;
  final Gradient? borderGradient;
  final Gradient? backgroundGradient;
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
    this.haptic = true,
  });

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
    final tappable = widget.onTap != null || widget.onLongPress != null;
    final radius = BorderRadius.circular(14);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: widget.padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.backgroundGradient == null ? AppColors.bgCard : null,
        gradient: widget.backgroundGradient,
        borderRadius: radius,
        border: widget.borderGradient == null
            ? Border.all(color: widget.borderColor ?? AppColors.border)
            : null,
        boxShadow: _pressed
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: widget.child,
    );

    if (widget.borderGradient != null) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: widget.borderGradient,
        ),
        padding: const EdgeInsets.all(1.2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: content,
        ),
      );
    }

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
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
