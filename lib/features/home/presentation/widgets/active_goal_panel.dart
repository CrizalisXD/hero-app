import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../../../core/widgets/hero_card.dart';
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
      return HeroCard(
        child: Row(
          children: [
            Expanded(child: Text(l.homeActiveGoalNone)),
            const SizedBox(width: AppSpacing.s),
            HeroButton(
              label: l.homeActiveGoalStart,
              variant: HeroButtonVariant.ghost,
              size: HeroButtonSize.sm,
              fullWidth: false,
              onPressed: () => context.go('/goals/new'),
            ),
          ],
        ),
      );
    }

    final categoryColor = AppColors.categoryColor(goal!.mainCategory.wire);

    return HeroCard.hero(
      onTap: () => context.go('/goals/${goal!.id}'),
      gradient: LinearGradient(
        colors: [categoryColor.withValues(alpha: 0.7), AppColors.accent],
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
                  color: AppColors.textSecondary,
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
            const SizedBox(height: AppSpacing.m),
            AnimatedFillBar(
              progress: progress!.taskProgress,
              height: 6,
              color: categoryColor,
            ),
            const SizedBox(height: 4),
            Text(
              l.homeActiveGoalProgress(
                progress!.tasksDone,
                progress!.tasksTotal,
              ),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
