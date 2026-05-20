import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentDim,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$xp XP',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
