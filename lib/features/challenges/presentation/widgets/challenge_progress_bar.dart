import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/animated_fill_bar.dart';

class ChallengeProgressBar extends StatelessWidget {
  const ChallengeProgressBar({super.key, required this.value});

  /// 0..1.
  final double value;

  @override
  Widget build(BuildContext context) {
    return AnimatedFillBar(
      progress: value,
      height: 8,
      gradient: AppColors.xpGradient,
      radius: 6,
    );
  }
}
