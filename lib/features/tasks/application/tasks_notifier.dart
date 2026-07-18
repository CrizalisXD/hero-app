import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_tasks_repository.dart';
import '../domain/models/create_task_input.dart';
import '../domain/models/task.dart';
import '../domain/models/task_completion_result.dart';
import '../domain/tasks_repository.dart';

// Returned by completeTask — caller decides how to surface feedback.
class TaskCompleteOutcome {
  const TaskCompleteOutcome({required this.result, required this.rolledBack});
  final TaskCompletionResult? result;
  final bool rolledBack;
}

class TasksNotifier extends AsyncNotifier<List<Task>> {
  TasksRepository get _repo => ref.read(tasksRepositoryProvider);

  @override
  Future<List<Task>> build() => _repo.getTasks();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getTasks());
  }

  /// Refetch without flashing a loading spinner: keeps the current list on
  /// screen and swaps in fresh data on success (drops it on error). Used to
  /// reconcile after a completion — e.g. a recurring task whose next instance
  /// the server just generated — without tearing down the list.
  Future<void> silentRefresh() async {
    final fresh = await AsyncValue.guard(() => _repo.getTasks());
    if (fresh is AsyncData<List<Task>>) state = fresh;
  }

  Future<Task?> createTask(CreateTaskInput input) async {
    try {
      final task = await _repo.createTask(input);
      state = AsyncData([task, ...state.valueOrNull ?? []]);
      return task;
    } catch (_) {
      return null;
    }
  }

  Future<TaskCompleteOutcome> completeTask(String taskId) async {
    final previous = state.valueOrNull;
    if (previous == null) {
      return const TaskCompleteOutcome(result: null, rolledBack: false);
    }

    // Optimistic: mark done locally.
    state = AsyncData(
      previous.map((t) {
        if (t.id != taskId) return t;
        return t.copyWith(isDone: true, completedAt: DateTime.now());
      }).toList(),
    );

    try {
      final result = await _repo.completeTask(taskId);
      if (!result.ok && !result.duplicate) {
        // Server rejected — roll back.
        state = AsyncData(previous);
        return TaskCompleteOutcome(result: result, rolledBack: true);
      }
      return TaskCompleteOutcome(result: result, rolledBack: false);
    } catch (_) {
      state = AsyncData(previous);
      return const TaskCompleteOutcome(result: null, rolledBack: true);
    }
  }

  /// Undo for a just-completed task. Optimistically flips is_done back
  /// to false and asks the server to reverse XP / ledger.
  Future<void> uncompleteTask(String taskId) async {
    final previous = state.valueOrNull ?? const <Task>[];
    final updated = previous.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(isDone: false, completedAt: null);
    }).toList();
    state = AsyncData(updated);
    try {
      await _repo.uncompleteTask(taskId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// Persists an edit to an existing task and replaces it in the list.
  /// Returns the updated task on success, or null on failure so the caller
  /// can surface an error without throwing.
  Future<Task?> updateTask(Task task) async {
    final previous = state.valueOrNull;
    try {
      final updated = await _repo.updateTask(task);
      if (previous != null) {
        state = AsyncData(
          previous.map((t) => t.id == updated.id ? updated : t).toList(),
        );
      }
      return updated;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteTask(String taskId) async {
    final previous = state.valueOrNull ?? [];
    state = AsyncData(previous.where((t) => t.id != taskId).toList());
    try {
      await _repo.deleteTask(taskId);
    } catch (_) {
      state = AsyncData(previous);
    }
  }
}

final tasksNotifierProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

/// "Today" = pending tasks whose [Task.dueAt] falls before tomorrow's local
/// midnight (so today's tasks scheduled later AND overdue ones both surface).
/// Tasks without a due_at live only in the All tab. Mirrors the server-side
/// `getTodayTasks()` query so the derived view matches a fresh fetch.
///
/// Pure + top-level so it's unit-testable without a repository.
List<Task> filterTodayTasks(List<Task> all, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final tomorrowMidnight = DateTime(n.year, n.month, n.day + 1);
  final today = all.where((t) {
    return !t.isDone &&
        t.dueAt != null &&
        t.dueAt!.isBefore(tomorrowMidnight);
  }).toList()
    ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
  return today;
}

/// Read-only Today view derived from the single [tasksNotifierProvider]
/// source of truth. There is no second notifier to keep in sync: any mutation
/// through TasksNotifier re-derives this automatically.
final todayTasksProvider = Provider<AsyncValue<List<Task>>>((ref) {
  return ref.watch(tasksNotifierProvider).whenData(filterTodayTasks);
});
