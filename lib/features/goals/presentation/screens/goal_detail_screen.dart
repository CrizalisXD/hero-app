import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../application/goals_notifier.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_progress.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(goalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalDetailTitle),
        leading: BackButton(onPressed: () => context.go('/goals')),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.goalsLoadError)),
        data: (view) {
          Goal? goal;
          for (final g in view.goals) {
            if (g.id == goalId) {
              goal = g;
              break;
            }
          }
          if (goal == null) {
            return Center(child: Text(l.goalsLoadError));
          }
          final progress = view.progressFor(goalId);
          return _GoalDetailBody(goal: goal, progress: progress);
        },
      ),
    );
  }
}

class _GoalDetailBody extends StatelessWidget {
  const _GoalDetailBody({required this.goal, this.progress});
  final Goal goal;
  final GoalProgress? progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tasksDone = progress?.tasksDone ?? 0;
    final tasksTotal = progress?.tasksTotal ?? 0;
    final milestonesDone = progress?.milestonesDone ?? 0;
    final milestonesTotal = progress?.milestonesTotal ?? 0;
    final taskPercent = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;

    return RefreshIndicator(
      onRefresh: () async {}, // no-op; data refreshes via provider
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Title & status ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(goal.title, style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: goal.status),
            ],
          ),

          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(goal.description!, style: theme.textTheme.bodyMedium),
          ],

          const SizedBox(height: 20),

          // ── Progress ─────────────────────────────────────────────
          Text(
            l.goalDetailProgressTasks(tasksDone, tasksTotal),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: taskPercent),
          const SizedBox(height: 12),
          Text(
            l.goalDetailProgressMilestones(milestonesDone, milestonesTotal),
            style: theme.textTheme.bodyMedium,
          ),

          if (goal.targetDate != null) ...[
            const SizedBox(height: 20),
            Text(
              '📅 ${_formatDate(goal.targetDate!)}',
              style: theme.textTheme.bodySmall,
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),

          // ── Related items placeholders ────────────────────────────
          ListTile(
            dense: true,
            leading: const Icon(Icons.check_box_outline_blank),
            title: Text(l.goalDetailRelatedTasks),
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.repeat),
            title: Text(l.goalDetailRelatedHabits),
            trailing: const Icon(Icons.chevron_right),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.flag_outlined),
            title: Text(l.goalDetailRelatedMilestones),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
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
