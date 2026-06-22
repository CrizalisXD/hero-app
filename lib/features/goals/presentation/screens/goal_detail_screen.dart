import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_radius.dart';
import '../../../../../app/theme/app_spacing.dart';
import '../../../../../core/l10n/l10n.dart';
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
    final taskPct = tasksTotal == 0 ? 0.0 : tasksDone / tasksTotal;
    final msPct = msTotal == 0 ? 0.0 : msDone / msTotal;

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

    final separated = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      separated.add(rows[i]);
      if (i != rows.length - 1) {
        separated.add(
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        );
      }
    }

    return HeroCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.m),
            AnimatedFillBar(
              progress: progress!,
              height: 6,
              color: accent,
              radius: AppRadius.s,
            ),
          ],
          const SizedBox(height: AppSpacing.s),
          ...separated,
        ],
      ),
    );
  }
}

/// Tappable circular checkbox with a ≥44px hit target and a done/busy state.
class _CheckCircle extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final enabled = onTap != null && !done && !busy;
    return Semantics(
      button: true,
      checked: done,
      child: InkResponse(
        onTap: enabled ? onTap : null,
        radius: 24,
        containedInkWell: true,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  )
                : AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? color : Colors.transparent,
                      border: Border.all(
                        color: done ? color : AppColors.textMuted,
                        width: 2,
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
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

  Future<void> _complete(BuildContext context, WidgetRef ref, Task task) async {
    try {
      final outcome =
          await ref.read(tasksNotifierProvider.notifier).completeTask(task.id);
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
    final done = tasks.where((t) => t.isDone).length;
    return _SectionCard(
      icon: Icons.check_circle_outline,
      accent: AppColors.accent,
      title: l.goalDetailRelatedTasks,
      countLabel: '$done/${tasks.length}',
      progress: tasks.isEmpty ? 0 : done / tasks.length,
      rows: tasks
          .map(
            (t) => _ItemRow(
              leading: _CheckCircle(
                done: t.isDone,
                color: AppColors.accent,
                onTap: () => _complete(context, ref, t),
              ),
              title: t.title,
              done: t.isDone,
              subtitle: t.description,
            ),
          )
          .toList(),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return _SectionCard(
      icon: Icons.local_fire_department_outlined,
      accent: AppColors.endurance,
      title: l.goalDetailRelatedHabits,
      rows: habits.map((h) {
        final isBad = h.type == HabitType.bad;
        return _HabitRow(
          isBad: isBad,
          title: h.title,
          streakLabel: isBad
              ? l.habitDaysCleanLabel(h.currentStreak)
              : l.habitStreakDays(h.currentStreak),
          actionLabel: isBad ? l.habitSlipAction : l.habitCheckinAction,
          onAction: () => _checkin(context, ref, h),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
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
      rows: widget.milestones
          .map(
            (m) => _ItemRow(
              leading: _CheckCircle(
                done: m.isDone,
                color: AppColors.social,
                busy: _busy.contains(m.id),
                onTap: () => _complete(m),
              ),
              title: m.title,
              done: m.isDone,
              subtitle: m.description,
              trailing: m.isDone ? null : XpBadge(xp: m.xpReward),
            ),
          )
          .toList(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
    };
    final color = switch (status) {
      GoalStatus.active => AppColors.success,
      GoalStatus.completed => AppColors.info,
      GoalStatus.paused => AppColors.warning,
      GoalStatus.abandoned => AppColors.textMuted,
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: 5),
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
