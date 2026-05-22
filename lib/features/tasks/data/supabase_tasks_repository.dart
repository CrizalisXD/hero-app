import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    // Show tasks where due_at <= now (tasks without due_at go in All tab only).
    final iso = DateTime.now().toUtc().toIso8601String();
    final rows = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .eq('is_done', false)
        .lte('due_at', iso)
        .order('due_at', ascending: true);
    return rows.map((r) => Task.fromJson(r)).toList();
  }

  @override
  Future<List<Task>> getTasks({String? goalId, bool? isDone}) async {
    var query = _client.from('tasks').select().eq('user_id', _userId);
    if (goalId != null) query = query.eq('goal_id', goalId);
    if (isDone != null) query = query.eq('is_done', isDone);
    final rows = await query.order('created_at', ascending: false);
    return rows.map((r) => Task.fromJson(r)).toList();
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
    late final dynamic raw;
    try {
      raw = await _client.rpc<dynamic>(
        'complete_task',
        params: {'p_task_id': taskId},
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'complete_task PostgrestException: ${e.code} | ${e.message} | ${e.details}',
      );
      rethrow;
    }

    debugPrint('=== complete_task RAW res: ${raw.runtimeType} :: $raw');

    final Map<String, dynamic> map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
      map = Map<String, dynamic>.from(raw.first as Map);
    } else {
      throw StateError(
        'complete_task: unexpected payload type ${raw.runtimeType}: $raw',
      );
    }

    if (map['ok'] != true) {
      throw StateError('complete_task rejected: ${map['error'] ?? map}');
    }
    return TaskCompletionResult.fromRpc(map);
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
