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

  Future<void> refreshToday() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getTodayTasks());
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

// Separate notifier that loads only today's pending tasks.
class TodayTasksNotifier extends AsyncNotifier<List<Task>> {
  TasksRepository get _repo => ref.read(tasksRepositoryProvider);

  @override
  Future<List<Task>> build() => _repo.getTodayTasks();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getTodayTasks());
  }

  Future<TaskCompleteOutcome> completeTask(String taskId) async {
    final previous = state.valueOrNull;
    if (previous == null) {
      return const TaskCompleteOutcome(result: null, rolledBack: false);
    }

    state = AsyncData(
      previous.map((t) {
        if (t.id != taskId) return t;
        return t.copyWith(isDone: true, completedAt: DateTime.now());
      }).toList(),
    );

    try {
      final result = await _repo.completeTask(taskId);
      if (!result.ok && !result.duplicate) {
        state = AsyncData(previous);
        return TaskCompleteOutcome(result: result, rolledBack: true);
      }
      return TaskCompleteOutcome(result: result, rolledBack: false);
    } catch (_) {
      state = AsyncData(previous);
      return const TaskCompleteOutcome(result: null, rolledBack: true);
    }
  }
}

final todayTasksNotifierProvider =
    AsyncNotifierProvider<TodayTasksNotifier, List<Task>>(
  TodayTasksNotifier.new,
);
