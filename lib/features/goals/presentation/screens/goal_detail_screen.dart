import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/notifications/widgets/reminder_sheet.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../../../core/widgets/hero_card.dart';
import '../../../../../core/widgets/xp_badge.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../habits/application/habits_notifier.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/domain/models/habit_type.dart';
import '../../../tasks/application/tasks_notifier.dart';
import '../../../tasks/domain/models/task.dart';
import '../../application/goal_children_notifier.dart';
import '../../application/goal_creation_notifier.dart';
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

    Goal? currentGoal;
    final view = goalsState.value;
    if (view != null) {
      for (final g in view.goals) {
        if (g.id == goalId) {
          currentGoal = g;
          break;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalDetailTitle),
        leading: BackButton(onPressed: () => context.go('/goals')),
        actions: [
          if (currentGoal != null)
            _GoalActionsMenu(goal: currentGoal),
        ],
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
    final childrenAsync = ref.watch(goalChildrenProvider(goal.id));
    final catColor = AppColors.categoryColor(goal.mainCategory.wire);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(goalChildrenProvider(goal.id));
        ref.invalidate(goalsNotifierProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.l),
        children: [
          _GoalHeaderCard(goal: goal, progress: progress, catColor: catColor),
          const SizedBox(height: AppSpacing.l),
          childrenAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Text('$e'),
            ),
            data: (children) {
              final empty = children.tasks.isEmpty &&
                  children.habits.isEmpty &&
                  children.milestones.isEmpty;
              if (empty) {
                return _EmptySteps(message: l.goalDetailNoSteps);
              }
              return Column(
                children: [
                  if (children.tasks.isNotEmpty) ...[
                    _TasksSection(tasks: children.tasks, goalId: goal.id),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  if (children.habits.isNotEmpty) ...[
                    _HabitsSection(habits: children.habits, goalId: goal.id),
                    const SizedBox(height: AppSpacing.m),
                  ],
                  if (children.milestones.isNotEmpty)
                    _MilestonesSection(
                      milestones: children.milestones,
                      goalId: goal.id,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Header (hero moment) ─────────────────────────────────────────────────────

class _GoalHeaderCard extends StatelessWidget {
  const _GoalHeaderCard({
    required this.goal,
    required this.progress,
    required this.catColor,
  });
  final Goal goal;
  final GoalProgress? progress;
  final Color catColor;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);

    final tasksDone = progress?.tasksDone ?? 0;
    final tasksTotal = progress?.tasksTotal ?? 0;
    final msDone = progress?.milestonesDone ?? 0;
    final msTotal = progress?.milestonesTotal ?? 0;
    // Clamped: stale counters can briefly report done > total — the bar
    // (and the % label) must not overflow past 100%.
    final taskPct =
        tasksTotal == 0 ? 0.0 : (tasksDone / tasksTotal).clamp(0.0, 1.0);
    final msPct = msTotal == 0 ? 0.0 : (msDone / msTotal).clamp(0.0, 1.0);

    return HeroCard.hero(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [catColor, AppColors.accentBright],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              _StatusBadge(status: goal.status),
            ],
          ),
          if (goal.description != null && goal.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              goal.description!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: AppSpacing.l),
          _ProgressLine(
            label: l.goalDetailProgressTasks(tasksDone, tasksTotal),
            value: taskPct,
            color: catColor,
          ),
          const SizedBox(height: AppSpacing.m),
          _ProgressLine(
            label: l.goalDetailProgressMilestones(msDone, msTotal),
            value: msPct,
            color: AppColors.social,
          ),
          if (goal.targetDate != null) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(goal.targetDate!),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedFillBar(
          progress: value,
          height: 8,
          color: color,
          radius: AppRadius.s,
        ),
      ],
    );
  }
}

// ── Reusable section card ────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.accent,
    required this.title,
    this.countLabel,
    this.progress,
    required this.rows,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? countLabel;
  final double? progress;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final body = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      body.add(rows[i]);
      if (i != rows.length - 1) {
        body.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
            child: Divider(height: 1, thickness: 1, color: AppColors.divider),
          ),
        );
      }
    }

    return HeroCard(
      padding: EdgeInsets.zero,
      // Clip so the full-bleed swipe action panes stay inside the rounded card.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                0,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.m),
                    ),
                    child: Icon(icon, size: 20, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (countLabel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        countLabel!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (progress != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.m,
                  AppSpacing.l,
                  0,
                ),
                child: AnimatedFillBar(
                  progress: progress!,
                  height: 6,
                  color: accent,
                  radius: AppRadius.s,
                ),
              ),
            const SizedBox(height: AppSpacing.s),
            ...body,
            const SizedBox(height: AppSpacing.s),
          ],
        ),
      ),
    );
  }
}

/// Tappable circular checkbox with a ≥44px hit target, a clear press animation
/// (scale + haptic) and a done/busy state.
class _CheckCircle extends StatefulWidget {
  const _CheckCircle({
    required this.done,
    required this.color,
    this.busy = false,
    this.onTap,
  });

  final bool done;
  final Color color;
  final bool busy;
  final VoidCallback? onTap;

  @override
  State<_CheckCircle> createState() => _CheckCircleState();
}

class _CheckCircleState extends State<_CheckCircle> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null && !widget.busy;

  void _setPressed(bool v) {
    if (!_enabled) return;
    if (mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final done = widget.done;
    final color = widget.color;

    return Semantics(
      button: true,
      checked: done,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: !_enabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                widget.onTap!();
              },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedScale(
              scale: _pressed ? 0.82 : 1.0,
              duration: Duration(milliseconds: reduceMotion ? 0 : 120),
              curve: Curves.easeOut,
              child: widget.busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    )
                  : AnimatedContainer(
                      duration: Duration(milliseconds: reduceMotion ? 0 : 180),
                      curve: Curves.easeOut,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? color
                            : (_pressed
                                ? color.withValues(alpha: 0.18)
                                : Colors.transparent),
                        border: Border.all(
                          color: done || _pressed ? color : AppColors.textMuted,
                          width: 2,
                        ),
                      ),
                      child: done
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tasks section ────────────────────────────────────────────────────────────

class _TasksSection extends ConsumerWidget {
  const _TasksSection({required this.tasks, required this.goalId});
  final List<Task> tasks;
  final String goalId;

  void _refresh(WidgetRef ref) {
    ref.invalidate(goalChildrenProvider(goalId));
    ref.invalidate(goalsNotifierProvider);
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Task task) async {
    try {
      final outcome =
          await ref.read(tasksNotifierProvider.notifier).completeTask(task.id);
      if (!context.mounted) return;
      _refresh(ref);
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

  Future<void> _uncomplete(WidgetRef ref, Task task) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).uncompleteTask(task.id);
      _refresh(ref);
    } catch (_) {}
  }

  Future<void> _delete(WidgetRef ref, Task task) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
      _refresh(ref);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final done = tasks.where((t) => t.isDone).length;
    return _SectionCard(
      icon: Icons.check_circle_outline,
      accent: AppColors.accent,
      title: l.goalDetailRelatedTasks,
      countLabel: '$done/${tasks.length}',
      progress: tasks.isEmpty ? 0 : done / tasks.length,
      rows: tasks.map((t) {
        return Slidable(
          key: ValueKey('goal-task-${t.id}'),
          // Right-swipe → instant complete (only when pending).
          startActionPane: t.isDone
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.25,
                  dismissible: DismissiblePane(
                    onDismissed: () => _complete(context, ref, t),
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _complete(context, ref, t),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: l.taskCompleteAction,
                    ),
                  ],
                ),
          // Left-swipe → reveal Undo (if done) + Delete.
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: t.isDone ? 0.5 : 0.25,
            children: [
              if (t.isDone)
                SlidableAction(
                  onPressed: (_) => _uncomplete(ref, t),
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  icon: Icons.undo,
                  label: l.commonUndo,
                ),
              SlidableAction(
                onPressed: (_) => _delete(ref, t),
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                label: l.commonDelete,
              ),
            ],
          ),
          child: _ItemRow(
            leading: _CheckCircle(
              done: t.isDone,
              color: AppColors.accent,
              onTap: () =>
                  t.isDone ? _uncomplete(ref, t) : _complete(context, ref, t),
            ),
            title: t.title,
            done: t.isDone,
            subtitle: t.description,
          ),
        );
      }).toList(),
    );
  }
}

// ── Habits section ───────────────────────────────────────────────────────────

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
      final res =
          await ref.read(habitsNotifierProvider.notifier).checkin(habit.id);
      if (!context.mounted) return;
      ref.invalidate(goalChildrenProvider(goalId));
      ref.invalidate(goalsNotifierProvider);
      if (res != null && !res.duplicate) {
        final isBad = habit.type == HabitType.bad;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBad ? context.l10n.habitSlipSnack : '+${res.totalXp} XP',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _uncheckin(WidgetRef ref, Habit habit) async {
    try {
      await ref.read(habitsNotifierProvider.notifier).uncheckin(habit.id);
      ref.invalidate(goalChildrenProvider(goalId));
      ref.invalidate(goalsNotifierProvider);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return _SectionCard(
      icon: Icons.local_fire_department_outlined,
      accent: AppColors.endurance,
      title: l.goalDetailRelatedHabits,
      rows: habits.map((h) {
        final isBad = h.type == HabitType.bad;
        final actionLabel = isBad ? l.habitSlipAction : l.habitCheckinAction;
        return Slidable(
          key: ValueKey('goal-habit-${h.id}'),
          // Right-swipe → check-in / mark slip.
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.28,
            children: [
              SlidableAction(
                onPressed: (_) => _checkin(context, ref, h),
                backgroundColor: isBad ? AppColors.badHabit : AppColors.success,
                foregroundColor: Colors.white,
                icon: isBad ? Icons.do_disturb_alt_outlined : Icons.check,
                label: actionLabel,
              ),
            ],
          ),
          // Left-swipe → undo today's check-in.
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.28,
            children: [
              SlidableAction(
                onPressed: (_) => _uncheckin(ref, h),
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                icon: Icons.undo,
                label: l.commonUndo,
              ),
            ],
          ),
          child: _HabitRow(
            isBad: isBad,
            title: h.title,
            streakLabel: isBad
                ? l.habitDaysCleanLabel(h.currentStreak)
                : l.habitStreakDays(h.currentStreak),
            actionLabel: actionLabel,
            onAction: () => _checkin(context, ref, h),
          ),
        );
      }).toList(),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.isBad,
    required this.title,
    required this.streakLabel,
    required this.actionLabel,
    required this.onAction,
  });

  final bool isBad;
  final String title;
  final String streakLabel;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isBad ? AppColors.badHabit : AppColors.endurance;
    return ColoredBox(
      // Solid bg so the row hides the swipe action pane underneath it.
      color: AppColors.bgCard,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        child: Row(
          children: [
            Icon(
              isBad ? Icons.do_disturb_alt_outlined : Icons.bolt,
              size: 22,
              color: color,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 13,
                        color: color.withValues(alpha: 0.9),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        streakLabel,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            HeroButton(
              label: actionLabel,
              variant: HeroButtonVariant.secondary,
              size: HeroButtonSize.sm,
              fullWidth: false,
              onPressed: onAction,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Milestones section ───────────────────────────────────────────────────────

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
      final map =
          raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
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

  Future<void> _uncomplete(Milestone m) async {
    if (_busy.contains(m.id) || !m.isDone) return;
    setState(() => _busy.add(m.id));
    try {
      final client = ref.read(supabaseClientProvider);
      await client.rpc<dynamic>(
        'uncomplete_milestone',
        params: {'p_milestone_id': m.id},
      );
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
    final done = widget.milestones.where((m) => m.isDone).length;
    return _SectionCard(
      icon: Icons.flag_outlined,
      accent: AppColors.social,
      title: l.goalDetailRelatedMilestones,
      countLabel: '$done/${widget.milestones.length}',
      progress: widget.milestones.isEmpty ? 0 : done / widget.milestones.length,
      rows: widget.milestones.map((m) {
        final busy = _busy.contains(m.id);
        return Slidable(
          key: ValueKey('goal-ms-${m.id}'),
          // Right-swipe → complete.
          startActionPane: m.isDone
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.25,
                  dismissible: DismissiblePane(onDismissed: () => _complete(m)),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _complete(m),
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      icon: Icons.check,
                      label: l.taskCompleteAction,
                    ),
                  ],
                ),
          // Left-swipe → undo (when done).
          endActionPane: m.isDone
              ? ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: 0.3,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _uncomplete(m),
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      icon: Icons.undo,
                      label: l.commonUndo,
                    ),
                  ],
                )
              : null,
          child: _ItemRow(
            leading: _CheckCircle(
              done: m.isDone,
              color: AppColors.social,
              busy: busy,
              onTap: () => m.isDone ? _uncomplete(m) : _complete(m),
            ),
            title: m.title,
            done: m.isDone,
            subtitle: m.description,
            trailing: m.isDone ? null : XpBadge(xp: m.xpReward),
          ),
        );
      }).toList(),
    );
  }
}

// ── Shared check-style row (tasks + milestones) ──────────────────────────────

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.leading,
    required this.title,
    required this.done,
    this.subtitle,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final bool done;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      // Solid bg so the row hides the swipe action pane underneath it.
      color: AppColors.bgCard,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s,
          2,
          AppSpacing.l,
          2,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? AppColors.textMuted : null,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: AppSpacing.s),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptySteps extends StatelessWidget {
  const _EmptySteps({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return HeroCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Column(
          children: [
            const Icon(
              Icons.auto_awesome_outlined,
              size: 28,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
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
      GoalStatus.extended => l.goalStatusExtended,
    };
    final color = switch (status) {
      GoalStatus.active => AppColors.success,
      GoalStatus.completed => AppColors.info,
      GoalStatus.paused => AppColors.warning,
      GoalStatus.abandoned => AppColors.textMuted,
      GoalStatus.extended => AppColors.accent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Goal actions menu (extend / rebuild / pause-resume) ──────────────────────

enum _GoalAction { extend, rebuild, pauseResume, reminder }

class _GoalActionsMenu extends ConsumerWidget {
  const _GoalActionsMenu({required this.goal});
  final Goal goal;

  Future<void> _extend(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initial = goal.targetDate != null && goal.targetDate!.isAfter(now)
        ? goal.targetDate!.add(const Duration(days: 30))
        : now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 1095)),
    );
    if (picked == null) return;
    await ref.read(goalsNotifierProvider.notifier).extendGoal(goal.id, picked);
  }

  void _rebuild(BuildContext context, WidgetRef ref) {
    ref.read(goalCreationProvider.notifier).startArchetypePick(
          title: goal.title,
          description: goal.description,
        );
    context.push('/goals/archetype');
  }

  Future<void> _pauseResume(WidgetRef ref) async {
    final next = goal.status == GoalStatus.paused
        ? GoalStatus.active
        : GoalStatus.paused;
    await ref.read(goalsNotifierProvider.notifier).setStatus(goal.id, next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isPaused = goal.status == GoalStatus.paused;
    return PopupMenuButton<_GoalAction>(
      onSelected: (action) {
        switch (action) {
          case _GoalAction.extend:
            _extend(context, ref);
          case _GoalAction.rebuild:
            _rebuild(context, ref);
          case _GoalAction.pauseResume:
            _pauseResume(ref);
          case _GoalAction.reminder:
            ReminderSheet.show(
              context,
              entityType: 'goal',
              entityId: goal.id,
              entityTitle: goal.title,
            );
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _GoalAction.reminder,
          child: Text(l.reminderAction),
        ),
        PopupMenuItem(
          value: _GoalAction.extend,
          child: Text(l.goalActionExtend),
        ),
        PopupMenuItem(
          value: _GoalAction.rebuild,
          child: Text(l.goalActionRebuild),
        ),
        PopupMenuItem(
          value: _GoalAction.pauseResume,
          child: Text(isPaused ? l.goalActionResume : l.goalActionPause),
        ),
      ],
    );
  }
}
