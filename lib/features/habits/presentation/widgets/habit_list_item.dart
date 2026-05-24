import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../domain/models/habit.dart';
import 'streak_badge.dart';

class HabitListItem extends StatelessWidget {
  const HabitListItem({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheckin,
    required this.onLongPress,
  });

  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheckin;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Check-in button
            GestureDetector(
              onTap: checkedToday ? null : onCheckin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: checkedToday ? AppColors.success : Colors.transparent,
                  border: Border.all(
                    color:
                        checkedToday ? AppColors.success : AppColors.accent,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: checkedToday
                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                    : const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.accent,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: checkedToday
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CategoryChip(
                        category: habit.mainCategory,
                        small: true,
                      ),
                      const SizedBox(width: 8),
                      StreakBadge(days: habit.currentStreak),
                      const SizedBox(width: 8),
                      Text(
                        '+${habit.xpReward} XP',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
