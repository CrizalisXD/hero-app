import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';

/// Small reward pill showing an XP gain, e.g. "+25 XP".
///
/// Styled as a "hero moment": accent gradient fill, a spark icon and a soft
/// glow so XP rewards feel earned rather than incidental.
class XpBadge extends StatelessWidget {
  final int xp;
  final double fontSize;

  const XpBadge({
    super.key,
    required this.xp,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(AppRadius.s),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: fontSize + 2, color: Colors.white),
          const SizedBox(width: 1),
          Text(
            '+$xp XP',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
