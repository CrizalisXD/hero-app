import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/models/task.dart';
import 'category_chip.dart';

/// Bidirectional slide actions per the user's request:
///   right-swipe (DismissDirection.startToEnd) → quick complete
///   left-swipe (DismissDirection.endToStart) → reveals action buttons:
///     • Удалить
///     • Отменить (only when task is done)
/// Tapping the leading circle still works as the primary tap target —
/// tapping a completed task uncompletes it (intuitive, matches iOS
/// Reminders / Things 3).
class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onUncomplete,
    required this.onDelete,
    this.onEdit,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onUncomplete;
  final VoidCallback onDelete;

  /// Tap on the row body (not the leading circle) opens the edit sheet.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.45);
    final l = context.l10n;

    return Slidable(
      key: ValueKey('task-${task.id}'),
      // Right-swipe: instant complete (only when not done).
      startActionPane: task.isDone
          ? null
          : ActionPane(
              motion: const StretchMotion(),
              extentRatio: 0.25,
              dismissible: DismissiblePane(onDismissed: onComplete),
              children: [
                SlidableAction(
                  onPressed: (_) => onComplete(),
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  icon: Icons.check,
                  label: l.taskCompleteAction,
                ),
              ],
            ),
      // Left-swipe: reveal Delete + (Undo if done).
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: task.isDone ? 0.55 : 0.30,
        dismissible: DismissiblePane(onDismissed: onDelete),
        children: [
          if (task.isDone)
            SlidableAction(
              onPressed: (_) => onUncomplete(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.undo,
              label: l.commonUndo,
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
      child: ListTile(
        onTap: onEdit,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          // Tap on the circle toggles state — natural undo:
          // checked task untaps back to active.
          onTap: task.isDone ? onUncomplete : onComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone
                  ? AppColors.accent
                  : Colors.transparent,
              border: Border.all(
                color: task.isDone
                    ? AppColors.accent
                    : theme.colorScheme.outline,
                width: 2,
              ),
            ),
            child: task.isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone
                ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              CategoryChip(category: task.mainCategory, small: true),
              if (task.dueAt != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule, size: 11, color: mutedColor),
                      const SizedBox(width: 4),
                      Text(
                        _shortDueAt(task.dueAt!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: Text(
          '+${task.xpReward} XP',
          style: TextStyle(
            color: AppColors.accent.withValues(alpha: task.isDone ? 0.4 : 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static const _monthsShort = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  static String _shortDueAt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final local = d.toLocal();
    final now = DateTime.now();
    final time = '${two(local.hour)}:${two(local.minute)}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return time;
    }
    return '${local.day} ${_monthsShort[local.month - 1]}, $time';
  }
}
