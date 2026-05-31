import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../../tasks/application/tasks_notifier.dart';
import '../../../tasks/domain/models/task.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../application/home_notifier.dart';
import 'level_up_overlay.dart';

class TodayFocusPanel extends ConsumerWidget {
  const TodayFocusPanel({super.key, required this.tasks});
  final List<Task> tasks;

  Future<void> _complete(BuildContext context, WidgetRef ref, Task t) async {
    try {
      final outcome =
          await ref.read(tasksNotifierProvider.notifier).completeTask(t.id);
      final res = outcome.result;
      if (!context.mounted || res == null || res.duplicate) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text('${context.l10n.taskCompleted} +${res.categoryXp} XP'),
        ),
      );
      if (res.levelsGained > 0 && context.mounted) {
        await LevelUpOverlay.show(context, newLevel: res.levelAfter);
        ref.invalidate(homeNotifierProvider);
      }
      if (res.unlockedAchievements.isNotEmpty && context.mounted) {
        await AchievementUnlockedSheet.showAll(
          context,
          res.unlockedAchievements,
        );
        ref.invalidate(achievementsNotifierProvider);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskCompleteError)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.homeFocusTitle,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (tasks.isEmpty)
                TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: Text(l.homeFocusAddTask),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Text(
              l.homeFocusEmpty,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xB3FFFFFF),
              ),
            )
          else
            ...tasks.map(
              (t) => _TaskRow(
                task: t,
                onComplete: () => _complete(context, ref, t),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task, required this.onComplete});
  final Task task;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: task.isDone ? null : onComplete,
            child: Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                color: task.isDone ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color:
                      task.isDone ? AppColors.success : AppColors.border,
                  width: 1.5,
                ),
                shape: BoxShape.circle,
              ),
              child: task.isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          CategoryChip(category: task.mainCategory),
        ],
      ),
    );
  }
}
