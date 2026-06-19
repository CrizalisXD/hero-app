import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import 'animated_fill_bar.dart';

/// Horizontal progress bar with label + numeric value.
///
/// Used for category XP, energy and any 0..max gauges. The fill is delegated to
/// [AnimatedFillBar] so motion + glow + reduced-motion behave consistently.
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final bool showValue;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    required this.color,
    this.showValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxValue == 0 ? 0.0 : value / maxValue;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: AnimatedFillBar(
            progress: progress,
            color: color,
          ),
        ),
        if (showValue) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
