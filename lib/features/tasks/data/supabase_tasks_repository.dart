import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/models/create_task_input.dart';
import '../domain/models/task.dart';
import '../domain/models/task_completion_result.dart';
import '../domain/tasks_repository.dart';

class SupabaseTasksRepository implements TasksRepository {
  SupabaseTasksRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<List<Task>> getTodayTasks() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    final rows = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .eq('is_done', false)
        .or('due_date.is.null,due_date.lte.$today')
        .order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Task.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Task>> getTasks({String? goalId, bool? isDone}) async {
    var query = _client.from('tasks').select().eq('user_id', _userId);
    if (goalId != null) query = query.eq('goal_id', goalId);
    if (isDone != null) query = query.eq('is_done', isDone);
    final rows =
        await query.order('created_at', ascending: false);
    return (rows as List<dynamic>)
        .map((r) => Task.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Task> createTask(CreateTaskInput input) async {
    final body = input.toInsertBody(userId: _userId);
    final row = await _client
        .from('tasks')
        .insert(body)
        .select()
        .single();
    return Task.fromJson(row);
  }

  @override
  Future<TaskCompletionResult> completeTask(String taskId) async {
    final dynamic result = await _client.rpc<dynamic>(
      'complete_task',
      params: {'p_task_id': taskId},
    );
    return TaskCompletionResult.fromRpc(
        Map<String, dynamic>.from(result as Map),);
  }

  @override
  Future<Task> updateTask(Task task) async {
    final row = await _client
        .from('tasks')
        .update({
          'title': task.title,
          'description': task.description,
          'difficulty': task.difficulty.wire,
          'duration': task.duration.wire,
          'importance': task.importance.wire,
          'due_date': task.dueDate?.toIso8601String().split('T').first,
        })
        .eq('id', task.id)
        .select()
        .single();
    return Task.fromJson(row);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _client.from('tasks').delete().eq('id', taskId);
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return SupabaseTasksRepository(Supabase.instance.client);
});
