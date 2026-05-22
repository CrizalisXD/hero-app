import 'package:flutter/material.dart';

import '../../domain/models/task.dart';
import 'category_chip.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
  });

  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedColor =
        theme.colorScheme.onSurface.withValues(alpha: 0.45);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.withValues(alpha: 0.8),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: task.isDone ? null : onComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isDone
                  ? const Color(0xFF7F77DD)
                  : Colors.transparent,
              border: Border.all(
                color: task.isDone
                    ? const Color(0xFF7F77DD)
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
                Icon(Icons.schedule, size: 12, color: mutedColor),
                const SizedBox(width: 2),
                Text(
                  _shortDueAt(task.dueAt!),
                  style: TextStyle(fontSize: 11, color: mutedColor),
                ),
              ],
            ],
          ),
        ),
        trailing: Text(
          '+${task.xpReward} XP',
          style: TextStyle(
            color: const Color(0xFF7F77DD)
                .withValues(alpha: task.isDone ? 0.4 : 0.9),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  static String _shortDueAt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return '${two(d.hour)}:${two(d.minute)}';
    }
    return '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }
}
