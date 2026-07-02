import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../../../../core/widgets/hero_card.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../application/goals_notifier.dart';
import '../../domain/models/goal.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(goalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.goalsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/new'),
        icon: const Icon(Icons.add),
        label: Text(l.goalsFabCreate),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.goalsLoadError, textAlign: TextAlign.center),
          ),
        ),
        data: (view) {
          if (view.goals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.goalsEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(goalsNotifierProvider.notifier).reload(),
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 96),
              itemCount: view.goals.length,
              separatorBuilder: (_, __) => const SizedBox.shrink(),
              itemBuilder: (_, i) {
                final goal = view.goals[i];
                final progress = view.progressFor(goal.id);
                return Dismissible(
                  key: ValueKey('goal-${goal.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 32),
                    color: AppColors.error.withValues(alpha: 0.8),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => ref
                      .read(goalsNotifierProvider.notifier)
                      .deleteGoal(goal.id),
                  child: _GoalTile(
                    goal: goal,
                    tasksDone: progress?.tasksDone ?? 0,
                    tasksTotal: progress?.tasksTotal ?? 0,
                    milestonesDone: progress?.milestonesDone ?? 0,
                    milestonesTotal: progress?.milestonesTotal ?? 0,
                    onTap: () => context.push('/goals/${goal.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.goal,
    required this.tasksDone,
    required this.tasksTotal,
    required this.milestonesDone,
    required this.milestonesTotal,
    required this.onTap,
  });

  final Goal goal;
  final int tasksDone;
  final int tasksTotal;
  final int milestonesDone;
  final int milestonesTotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final progress = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;
    final categoryColor = AppColors.categoryColor(goal.mainCategory.wire);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: HeroCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: goal.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CategoryChip(category: goal.mainCategory, small: true),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedFillBar(
              progress: progress,
              height: 6,
              color: categoryColor,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  l.goalDetailProgressTasks(tasksDone, tasksTotal),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                Text(
                  l.goalDetailProgressMilestones(milestonesDone, milestonesTotal),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final GoalStatus status;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final label = switch (status) {
      GoalStatus.active => l.goalStatusActive,
      GoalStatus.completed => l.goalStatusCompleted,
      GoalStatus.paused => l.goalStatusPaused,
      GoalStatus.abandoned => l.goalStatusAbandoned,
      GoalStatus.extended => l.goalStatusExtended,
    };
    final color = switch (status) {
      GoalStatus.active => AppColors.success,
      GoalStatus.completed => AppColors.info,
      GoalStatus.paused => AppColors.warning,
      GoalStatus.abandoned => AppColors.textMuted,
      GoalStatus.extended => AppColors.accent,
    };
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide.none,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
