import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_error_view.dart';
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
          _TaskTab(
            today: true,
            emptyLabel: l.tasksEmptyToday,
            onCreateTap: _openCreateSheet,
          ),
          _TaskTab(
            today: false,
            emptyLabel: l.tasksEmpty,
            onCreateTap: _openCreateSheet,
          ),
        ],
      ),
    );
  }
}

/// One tab of the tasks screen. [today] switches the read-only source between
/// the derived [todayTasksProvider] and the full [tasksNotifierProvider], but
/// every mutation flows through the single [TasksNotifier] — there is no
/// second notifier to keep in sync.
class _TaskTab extends ConsumerWidget {
  const _TaskTab({
    required this.today,
    required this.emptyLabel,
    required this.onCreateTap,
  });

  final bool today;
  final String emptyLabel;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = today
        ? ref.watch(todayTasksProvider)
        : ref.watch(tasksNotifierProvider);

    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => HeroErrorView(
        onRetry: () => ref.read(tasksNotifierProvider.notifier).refresh(),
      ),
      data: (tasks) => tasks.isEmpty
          ? _EmptyView(label: emptyLabel, onCreateTap: onCreateTap)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(tasksNotifierProvider.notifier).refresh(),
              child: _TaskList(
                tasks: tasks,
                onComplete: (id) => _handleComplete(context, ref, id),
                onUncomplete: (id) => _handleUncomplete(ref, id),
                onDelete: (id) =>
                    ref.read(tasksNotifierProvider.notifier).deleteTask(id),
              ),
            ),
    );
  }

  Future<void> _handleUncomplete(WidgetRef ref, String taskId) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).uncompleteTask(taskId);
      ref.invalidate(homeNotifierProvider);
    } catch (_) {}
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
      return;
    }

    // Quiet floating snack. Undo discovery lives on the checked circle and the
    // slide-action; the snack action is a third, fallback path.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          content: Text('${l.taskCompleted} +${result.categoryXp} XP'),
          action: SnackBarAction(
            label: l.commonUndo,
            onPressed: () => _handleUncomplete(ref, taskId),
          ),
        ),
      );

    await ref.read(homeNotifierProvider.notifier).silentRefresh();
    // Reconcile the list against the server (e.g. a recurring task whose next
    // instance was just generated) without flashing a loading spinner.
    await ref.read(tasksNotifierProvider.notifier).silentRefresh();

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
