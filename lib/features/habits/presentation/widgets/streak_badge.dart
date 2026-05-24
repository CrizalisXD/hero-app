import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

/// Flame icon + streak day count.
/// Color escalates: normal → warning (≥7) → epic (≥21).
class StreakBadge extends StatelessWidget {
  const StreakBadge({super.key, required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    if (days <= 0) return const SizedBox.shrink();

    final color = days >= 21
        ? AppColors.rarityEpic
        : days >= 7
            ? AppColors.warning
            : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '$days',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
