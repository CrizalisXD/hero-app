import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_type.dart';
import 'streak_badge.dart';

class HabitListItem extends StatelessWidget {
  const HabitListItem({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheckin,
    required this.onDelete,
  });

  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheckin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isBad = habit.type == HabitType.bad;
    // For a good habit, "checkedToday" means the user completed it.
    // For a bad habit, "checkedToday" means the user logged a slip today
    // — so the check-in button shouldn't be tappable again until tomorrow.
    final accentColor = isBad ? Colors.orange.shade400 : AppColors.accent;
    final doneColor = isBad ? Colors.red.shade400 : AppColors.success;

    // Bi-directional swipe — same UX as TaskListItem so the gesture
    // language is consistent across Tasks and Habits screens.
    //   Swipe RIGHT → check-in / slip-log (depending on habit.type).
    //   Swipe LEFT  → delete.
    return Dismissible(
      key: ValueKey(habit.id),
      direction: checkedToday
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: (isBad ? Colors.orange : Colors.green).withValues(alpha: 0.85),
        child: Icon(
          isBad ? Icons.do_disturb_alt : Icons.check,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (!checkedToday) onCheckin();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Check-in button. For bad habits the icon and color flip
            // (orange + 🚫) so users instantly see this is a slip log,
            // not a reward action.
            GestureDetector(
              onTap: checkedToday ? null : onCheckin,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: checkedToday ? doneColor : Colors.transparent,
                  border: Border.all(
                    color: checkedToday ? doneColor : accentColor,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: checkedToday
                    ? Icon(
                        isBad ? Icons.priority_high : Icons.check,
                        size: 20,
                        color: Colors.white,
                      )
                    : Icon(
                        isBad ? Icons.do_disturb_alt : Icons.add,
                        size: 18,
                        color: accentColor,
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
                      // For good habit: server streak. For bad: computed
                      // "days since last slip" (or since creation).
                      if (isBad)
                        Text(
                          l.habitDaysCleanLabel(habit.displayStreak),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else ...[
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
