import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../avatar/application/hero_emote_queue.dart';
import '../../../home/application/home_notifier.dart';
import '../../../home/presentation/widgets/level_up_overlay.dart';
import '../../application/routines_notifier.dart';
import '../../domain/models/routine.dart';
import 'routine_editor_screen.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  void _openEditor(BuildContext context, {Routine? routine}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutineEditorScreen(routine: routine),
      ),
    );
  }

  Future<void> _complete(
    BuildContext context,
    WidgetRef ref,
    Routine r,
  ) async {
    final res =
        await ref.read(routinesNotifierProvider.notifier).complete(r.id);
    if (!context.mounted || res == null || res.duplicate) return;
    final l = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          content: Text(l.routineCompletedSnack(res.xpAwarded)),
        ),
      );
    await ref.read(homeNotifierProvider.notifier).silentRefresh();
    if (res.levelsGained > 0 && context.mounted) {
      // Уровень взят вне Home — эмоция ждёт в очереди до возвращения к герою.
      celebrateLevelUp(ref);
      await LevelUpOverlay.show(context, newLevel: res.levelAfter);
      await ref.read(homeNotifierProvider.notifier).silentRefresh();
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Routine r) async {
    await ref.read(routinesNotifierProvider.notifier).deleteRoutine(r.id);
    await LocalNotificationsService.instance
        .cancelReminder(routineNotifId(r.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(routinesNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.navRoutines)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add),
        label: Text(l.routinesFabCreate),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.routinesLoadError, textAlign: TextAlign.center),
          ),
        ),
        data: (view) {
          if (view.routines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.routinesEmpty, textAlign: TextAlign.center),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(routinesNotifierProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final r in view.routines)
                  _RoutineCard(
                    key: ValueKey(r.id),
                    routine: r,
                    doneToday: view.isDoneToday(r.id),
                    onComplete: () => _complete(context, ref, r),
                    onUncomplete: () => ref
                        .read(routinesNotifierProvider.notifier)
                        .uncomplete(r.id),
                    onEdit: () => _openEditor(context, routine: r),
                    onDelete: () => _delete(context, ref, r),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoutineCard extends StatefulWidget {
  const _RoutineCard({
    super.key,
    required this.routine,
    required this.doneToday,
    required this.onComplete,
    required this.onUncomplete,
    required this.onEdit,
    required this.onDelete,
  });

  final Routine routine;
  final bool doneToday;
  final VoidCallback onComplete;
  final VoidCallback onUncomplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<_RoutineCard> {
  bool _expanded = false;
  final Set<int> _checked = {};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final r = widget.routine;
    final done = widget.doneToday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: HeroCard(
        borderColor: done ? AppColors.success.withValues(alpha: 0.5) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: done ? widget.onUncomplete : widget.onComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.success : Colors.transparent,
                      border: Border.all(
                        color: done ? AppColors.success : AppColors.accent,
                        width: 2,
                      ),
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: done
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        _MetaRow(routine: r),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (v) {
                    if (v == 'edit') widget.onEdit();
                    if (v == 'delete') widget.onDelete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l.commonEdit)),
                    PopupMenuItem(value: 'delete', child: Text(l.commonDelete)),
                  ],
                ),
                IconButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (_expanded) ...[
              const Divider(height: 16),
              for (var i = 0; i < r.steps.length; i++)
                _StepTile(
                  step: r.steps[i],
                  checked: done || _checked.contains(i),
                  onTap: done
                      ? null
                      : () => setState(() {
                            if (!_checked.add(i)) _checked.remove(i);
                          }),
                ),
              const SizedBox(height: 4),
              if (done)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l.routineDoneToday,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: widget.onComplete,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(l.routineCompleteAction),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.routine});
  final Routine routine;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final total = routine.totalMinutes;
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (routine.currentStreak > 0)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 13,
                color: AppColors.endurance,
              ),
              const SizedBox(width: 2),
              Text(
                l.habitStreakDays(routine.currentStreak),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        Text(
          l.routineStepsCount(routine.steps.length),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        if (total > 0)
          Text(
            l.routineMinutes(total),
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        if (routine.reminderEnabled && routine.scheduledTime != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 12,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 2),
              Text(
                routine.scheduledTime!,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
      ],
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.checked,
    required this.onTap,
  });

  final RoutineStep step;
  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.s),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 20,
              color: checked ? AppColors.success : AppColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                step.title,
                style: TextStyle(
                  fontSize: 14,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
            ),
            if (step.durationMinutes != null)
              Text(
                l.routineMinutes(step.durationMinutes!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
