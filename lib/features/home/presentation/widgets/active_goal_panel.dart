import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../goals/domain/models/goal.dart';
import '../../../goals/domain/models/goal_progress.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';

class ActiveGoalPanel extends StatelessWidget {
  const ActiveGoalPanel({
    super.key,
    required this.goal,
    required this.progress,
  });

  final Goal? goal;
  final GoalProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    if (goal == null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(child: Text(l.homeActiveGoalNone)),
            TextButton(
              onPressed: () => context.go('/goals/new'),
              child: Text(l.homeActiveGoalStart),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => context.go('/goals/${goal!.id}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
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
                  l.homeActiveGoal,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xB3FFFFFF),
                  ),
                ),
                const Spacer(),
                CategoryChip(category: goal!.mainCategory),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              goal!.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress!.taskProgress,
                  backgroundColor: AppColors.bgElevated,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l.homeActiveGoalProgress(
                  progress!.tasksDone,
                  progress!.tasksTotal,
                ),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xB3FFFFFF),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
