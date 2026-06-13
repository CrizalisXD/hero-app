import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../habits/application/habits_notifier.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/domain/models/habit_type.dart';
import '../../../tasks/application/tasks_notifier.dart';
import '../../../tasks/domain/models/task.dart';
import '../../application/goal_children_notifier.dart';
import '../../application/goals_notifier.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/goal_progress.dart';
import '../../domain/models/milestone.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});
  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final goalsState = ref.watch(goalsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalDetailTitle),
        leading: BackButton(onPressed: () => context.go('/goals')),
      ),
      body: goalsState.when(
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

class _GoalDetailBody extends ConsumerWidget {
  const _GoalDetailBody({required this.goal, this.progress});
  final Goal goal;
  final GoalProgress? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final childrenAsync = ref.watch(goalChildrenProvider(goal.id));

    final tasksDone = progress?.tasksDone ?? 0;
    final tasksTotal = progress?.tasksTotal ?? 0;
    final milestonesDone = progress?.milestonesDone ?? 0;
    final milestonesTotal = progress?.milestonesTotal ?? 0;
    final taskPercent = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(goalChildrenProvider(goal.id));
        ref.invalidate(goalsNotifierProvider);
      },
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

          // ── Expandable children ─────────────────────────────────
          childrenAsync.when(
            loading: () =>
                const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('$e'),
            ),
            data: (children) => Column(
              children: [
                if (children.tasks.isNotEmpty)
                  _TasksSection(tasks: children.tasks, goalId: goal.id),
                if (children.habits.isNotEmpty)
                  _HabitsSection(habits: children.habits, goalId: goal.id),
                if (children.milestones.isNotEmpty)
                  _MilestonesSection(
                    milestones: children.milestones,
                    goalId: goal.id,
                  ),
                if (children.tasks.isEmpty &&
                    children.habits.isEmpty &&
                    children.milestones.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l.goalDetailNoSteps,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Tasks section ──────────────────────────────────────────────────────────

class _TasksSection extends ConsumerWidget {
  const _TasksSection({required this.tasks, required this.goalId});
  final List<Task> tasks;
  final String goalId;

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    try {
      final outcome = await ref
          .read(tasksNotifierProvider.notifier)
          .completeTask(task.id);
      if (!context.mounted) return;
      ref.invalidate(goalChildrenProvider(goalId));
      ref.invalidate(goalsNotifierProvider);
      final r = outcome.result;
      if (r != null && !r.duplicate) {
        final xp = r.categoryXp + r.disciplineXp;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$xp XP'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.check_box_outlined),
      title: Text(
        '${l.goalDetailRelatedTasks} · ${tasks.where((t) => t.isDone).length}/${tasks.length}',
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: tasks
          .map(
            (t) => CheckboxListTile(
              dense: true,
              value: t.isDone,
              onChanged: t.isDone
                  ? null
                  : (_) => _complete(context, ref, t),
              title: Text(
                t.title,
                style: t.isDone
                    ? const TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      )
                    : null,
              ),
              subtitle: t.description == null || t.description!.isEmpty
                  ? null
                  : Text(
                      t.description!,
                      style: const TextStyle(fontSize: 11),
                    ),
            ),
          )
          .toList(),
    );
  }
}

// ── Habits section ─────────────────────────────────────────────────────────

class _HabitsSection extends ConsumerWidget {
  const _HabitsSection({required this.habits, required this.goalId});
  final List<Habit> habits;
  final String goalId;

  Future<void> _checkin(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) async {
    try {
      final res = await ref
          .read(habitsNotifierProvider.notifier)
          .checkin(habit.id);
      if (!context.mounted) return;
      ref.invalidate(goalChildrenProvider(goalId));
      ref.invalidate(goalsNotifierProvider);
      if (res != null && !res.duplicate) {
        final isBad = habit.type == HabitType.bad;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBad
                  ? context.l10n.habitSlipSnack
                  : '+${res.totalXp} XP',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.local_fire_department_outlined),
      title: Text(l.goalDetailRelatedHabits),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: habits
          .map(
            (h) => ListTile(
              dense: true,
              leading: Icon(
                h.type == HabitType.bad
                    ? Icons.do_disturb_alt_outlined
                    : Icons.add_circle_outline,
                color: h.type == HabitType.bad
                    ? Colors.orange
                    : Colors.purpleAccent,
              ),
              title: Text(h.title),
              subtitle: Text(
                h.type == HabitType.bad
                    ? l.habitDaysCleanLabel(h.currentStreak)
                    : l.habitStreakDays(h.currentStreak),
                style: const TextStyle(fontSize: 11),
              ),
              trailing: TextButton(
                onPressed: () => _checkin(context, ref, h),
                child: Text(
                  h.type == HabitType.bad
                      ? l.habitSlipAction
                      : l.habitCheckinAction,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Milestones section ────────────────────────────────────────────────────

class _MilestonesSection extends ConsumerStatefulWidget {
  const _MilestonesSection({required this.milestones, required this.goalId});
  final List<Milestone> milestones;
  final String goalId;

  @override
  ConsumerState<_MilestonesSection> createState() => _MilestonesSectionState();
}

class _MilestonesSectionState extends ConsumerState<_MilestonesSection> {
  final _busy = <String>{};

  Future<void> _complete(Milestone m) async {
    if (_busy.contains(m.id) || m.isDone) return;
    setState(() => _busy.add(m.id));
    try {
      final client = ref.read(supabaseClientProvider);
      final raw = await client.rpc<dynamic>(
        'complete_milestone',
        params: {'p_milestone_id': m.id},
      );
      final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      if (map['ok'] == true && map['duplicate'] != true && mounted) {
        final xp = (map['xp_gained'] as num?)?.toInt() ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('+$xp XP'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
      ref.invalidate(goalChildrenProvider(widget.goalId));
      ref.invalidate(goalsNotifierProvider);
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${e.code}: ${e.message}')),
        );
      }
    } catch (_) {}
    if (mounted) setState(() => _busy.remove(m.id));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.flag_outlined),
      title: Text(
        '${l.goalDetailRelatedMilestones} · ${widget.milestones.where((m) => m.isDone).length}/${widget.milestones.length}',
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
      children: widget.milestones
          .map(
            (m) => CheckboxListTile(
              dense: true,
              value: m.isDone,
              onChanged: m.isDone || _busy.contains(m.id)
                  ? null
                  : (_) => _complete(m),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      m.title,
                      style: m.isDone
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                  ),
                  Text(
                    '+${m.xpReward} XP',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              subtitle: m.description == null || m.description!.isEmpty
                  ? null
                  : Text(
                      m.description!,
                      style: const TextStyle(fontSize: 11),
                    ),
            ),
          )
          .toList(),
    );
  }
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
