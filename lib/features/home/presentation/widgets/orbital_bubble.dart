import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/app_colors.dart';

/// A circular "bubble" quick-action that floats around the hero on Home.
///
/// Icon in an accent-tinted glassy circle with an optional count badge and a
/// label underneath. Press-scales for tactile feedback.
class OrbitalBubble extends StatefulWidget {
  const OrbitalBubble({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.color,
    this.size = 60,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Small count/status text shown in the top-right badge (e.g. "3", "1/3").
  final String? badge;
  final Color? color;
  final double size;

  @override
  State<OrbitalBubble> createState() => _OrbitalBubbleState();
}

class _OrbitalBubbleState extends State<OrbitalBubble> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.accent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: widget.size,
                  width: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.28),
                        color.withValues(alpha: 0.10),
                      ],
                    ),
                    border: Border.all(
                      color: color.withValues(alpha: 0.55),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.30),
                        blurRadius: 16,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: color, size: widget.size * 0.42),
                ),
                if (widget.badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 20),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.bg, width: 2),
                      ),
                      child: Text(
                        widget.badge!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
