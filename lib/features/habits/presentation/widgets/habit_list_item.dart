import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_type.dart';
import 'streak_badge.dart';

/// Bidirectional slide actions:
///   right-swipe → check-in (full swipe dismisses to act)
///   left-swipe  → reveals action buttons:
///     • Удалить (always)
///     • Пропустить (only when not checked yet)
///     • Отменить (only when checked today)
class HabitListItem extends StatelessWidget {
  const HabitListItem({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheckin,
    required this.onUncheckin,
    required this.onSkip,
    required this.onDelete,
  });

  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheckin;
  final VoidCallback onUncheckin;
  final VoidCallback onSkip;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isBad = habit.type == HabitType.bad;
    final accentColor = isBad ? AppColors.warning : AppColors.accent;
    final doneColor = isBad ? AppColors.error : AppColors.success;

    return Slidable(
      key: ValueKey('habit-${habit.id}'),
      startActionPane: checkedToday
          ? null
          : ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(onDismissed: onCheckin),
              children: [
                SlidableAction(
                  onPressed: (_) => onCheckin(),
                  backgroundColor: isBad ? AppColors.warning : AppColors.success,
                  foregroundColor: Colors.white,
                  icon: isBad ? Icons.do_disturb_alt : Icons.check,
                  label: isBad ? l.habitSlipAction : l.habitCheckinAction,
                ),
              ],
            ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        // Wider extent when there are 2 actions (delete + skip OR
        // delete + undo) vs 1 (delete only when nothing else applies).
        extentRatio: 0.55,
        dismissible: DismissiblePane(onDismissed: onDelete),
        children: [
          if (checkedToday)
            SlidableAction(
              onPressed: (_) => onUncheckin(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.undo,
              label: l.commonUndo,
            )
          else
            SlidableAction(
              onPressed: (_) => onSkip(),
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              icon: Icons.skip_next,
              label: l.habitSkipAction,
            ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: l.commonDelete,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              // Tap toggles: checked → uncheckin, unchecked → checkin.
              onTap: checkedToday ? onUncheckin : onCheckin,
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
