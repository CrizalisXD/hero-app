import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
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
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: view.goals.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final goal = view.goals[i];
                final progress = view.progressFor(goal.id);
                return Dismissible(
                  key: ValueKey('goal-${goal.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.withValues(alpha: 0.8),
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
    final progress = tasksTotal == 0
        ? 0.0
        : tasksDone / tasksTotal;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        goal.title,
        style: theme.textTheme.titleMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress, minHeight: 4),
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
      trailing: _StatusChip(status: goal.status),
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
    };
    final color = switch (status) {
      GoalStatus.active => Colors.green,
      GoalStatus.completed => Colors.blue,
      GoalStatus.paused => Colors.orange,
      GoalStatus.abandoned => Colors.grey,
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
