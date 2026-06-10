import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ChallengeProgressBar extends StatelessWidget {
  const ChallengeProgressBar({super.key, required this.value});

  /// 0..1.
  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 8,
        decoration: const BoxDecoration(color: AppColors.bgElevated),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.xpGradient),
            ),
          ),
        ),
      ),
    );
  }
}
