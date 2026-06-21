import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../home/application/home_notifier.dart';
import '../../../home/presentation/widgets/level_up_overlay.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../application/tasks_notifier.dart';
import '../../domain/models/task.dart';
import '../widgets/create_task_sheet.dart';
import '../widgets/task_list_item.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _openCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const CreateTaskSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tasksTitle),
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(text: l.tasksTabToday),
            Tab(text: l.tasksTabAll),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateSheet,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TodayTab(onCreateTap: _openCreateSheet),
          _AllTab(onCreateTap: _openCreateSheet),
        ],
      ),
    );
  }
}

// ─── Today tab ────────────────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  const _TodayTab({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(todayTasksNotifierProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () =>
            ref.read(todayTasksNotifierProvider.notifier).refresh(),
      ),
      data: (tasks) => tasks.isEmpty
          ? _EmptyView(label: l.tasksEmptyToday, onCreateTap: onCreateTap)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(todayTasksNotifierProvider.notifier).refresh(),
              child: _TaskList(
                tasks: tasks,
                onComplete: (id) => _handleComplete(context, ref, id),
                onUncomplete: (id) async {
                  // Tap or slide-action "Undo" — reverse the completion
                  // both locally (in both notifiers) and on the server.
                  try {
                    await ref
                        .read(tasksNotifierProvider.notifier)
                        .uncompleteTask(id);
                    await ref
                        .read(todayTasksNotifierProvider.notifier)
                        .uncompleteTask(id);
                    ref.invalidate(homeNotifierProvider);
                  } catch (_) {}
                },
                onDelete: (id) {
                  // Mirror into both notifiers so Today and All stay in sync.
                  ref
                      .read(todayTasksNotifierProvider.notifier)
                      .deleteTask(id);
                  ref.read(tasksNotifierProvider.notifier).deleteTask(id);
                },
              ),
            ),
    );
  }

  Future<void> _handleComplete(
    BuildContext context,
    WidgetRef ref,
    String taskId,
  ) async {
    final outcome = await ref
        .read(todayTasksNotifierProvider.notifier)
        .completeTask(taskId);

    if (!context.mounted) return;
    final l = context.l10n;

    if (outcome.rolledBack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.taskCompleteError)),
      );
      return;
    }

    final result = outcome.result;
    if (result == null) return;

    if (result.duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.taskDuplicate)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l.taskCompleted} +${result.categoryXp} XP',
          ),
        ),
      );
      await ref.read(homeNotifierProvider.notifier).silentRefresh();
      ref.invalidate(tasksNotifierProvider);
      if (result.levelsGained > 0 && context.mounted) {
        await LevelUpOverlay.show(context, newLevel: result.levelAfter);
        await ref.read(homeNotifierProvider.notifier).silentRefresh();
      }
      if (result.unlockedAchievements.isNotEmpty && context.mounted) {
        await AchievementUnlockedSheet.showAll(
          context,
          result.unlockedAchievements,
        );
        ref.invalidate(achievementsNotifierProvider);
      }
    }
  }
}

// ─── All tab ──────────────────────────────────────────────────────────────────

class _AllTab extends ConsumerWidget {
  const _AllTab({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(tasksNotifierProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () =>
            ref.read(tasksNotifierProvider.notifier).refresh(),
      ),
      data: (tasks) => tasks.isEmpty
          ? _EmptyView(label: l.tasksEmpty, onCreateTap: onCreateTap)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(tasksNotifierProvider.notifier).refresh(),
              child: _TaskList(
                tasks: tasks,
                onComplete: (id) => _handleComplete(context, ref, id),
                onUncomplete: (id) async {
                  try {
                    await ref
                        .read(tasksNotifierProvider.notifier)
                        .uncompleteTask(id);
                    ref.invalidate(homeNotifierProvider);
                  } catch (_) {}
                },
                onDelete: (id) =>
                    ref.read(tasksNotifierProvider.notifier).deleteTask(id),
              ),
            ),
    );
  }

  Future<void> _handleComplete(
    BuildContext context,
    WidgetRef ref,
    String taskId,
  ) async {
    final outcome =
        await ref.read(tasksNotifierProvider.notifier).completeTask(taskId);

    if (!context.mounted) return;
    final l = context.l10n;

    if (outcome.rolledBack) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.taskCompleteError)),
      );
      return;
    }

    final result = outcome.result;
    if (result == null) return;

    if (result.duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.taskDuplicate)),
      );
    } else {
      // Quiet floating snack. Undo discovery moved off the snack:
      // tap the checked circle or use the slide-action "Undo" button.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            content: Text('${l.taskCompleted} +${result.categoryXp} XP'),
            action: SnackBarAction(
              // Kept as a fallback for users who instinctively reach for
              // the snack action — it's the same flow, just a third path
              // alongside tap-toggle and slide-action.
              label: l.commonUndo,
              onPressed: () async {
                try {
                  await ref
                      .read(tasksNotifierProvider.notifier)
                      .uncompleteTask(taskId);
                  await ref
                      .read(todayTasksNotifierProvider.notifier)
                      .uncompleteTask(taskId);
                  ref.invalidate(homeNotifierProvider);
                } catch (_) {}
              },
            ),
          ),
        );
      await ref.read(homeNotifierProvider.notifier).silentRefresh();
      ref.invalidate(todayTasksNotifierProvider);
      if (result.levelsGained > 0 && context.mounted) {
        await LevelUpOverlay.show(context, newLevel: result.levelAfter);
        await ref.read(homeNotifierProvider.notifier).silentRefresh();
      }
      if (result.unlockedAchievements.isNotEmpty && context.mounted) {
        await AchievementUnlockedSheet.showAll(
          context,
          result.unlockedAchievements,
        );
        ref.invalidate(achievementsNotifierProvider);
      }
    }
  }
}

// ─── Shared sub-widgets ────────────────────────────────────────────────────────

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.onComplete,
    required this.onUncomplete,
    required this.onDelete,
  });

  final List<Task> tasks;
  final void Function(String taskId) onComplete;
  final void Function(String taskId) onUncomplete;
  final void Function(String taskId) onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
      itemBuilder: (_, i) => TaskListItem(
        task: tasks[i],
        onComplete: () => onComplete(tasks[i].id),
        onUncomplete: () => onUncomplete(tasks[i].id),
        onDelete: () => onDelete(tasks[i].id),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.label, required this.onCreateTap});
  final String label;

  /// Kept for call-site compatibility; creating now lives in the bottom-right
  /// FAB (consistent with the other screens), so the empty state is just a
  /// calm hint.
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.checklist_rtl,
            size: 44,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 8),
          Text(message),
          const SizedBox(height: 16),
          HeroButton(
            label: context.l10n.homeRetry,
            fullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
