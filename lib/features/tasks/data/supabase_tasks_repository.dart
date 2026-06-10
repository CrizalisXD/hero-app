import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../integrations/calendar/data/device_calendar_service.dart';
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
    final task = Task.fromJson(row);

    // Phase 15: best-effort calendar mirror when the user opted into it.
    // Never blocks task creation — _maybeMirrorToCalendar swallows errors.
    if (task.dueAt != null) {
      unawaited(_maybeMirrorToCalendar(task));
    }
    return task;
  }

  Future<void> _maybeMirrorToCalendar(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sync = prefs.getBool('cal_sync_tasks') ?? false;
      final calId = prefs.getString('cal_default_id');
      if (!sync || calId == null) return;

      // Consent gate — never write to calendar without explicit opt-in.
      final consent = await _client
          .from('user_consents')
          .select('granted')
          .eq('consent_key', 'integration_calendar_write')
          .maybeSingle();
      if ((consent?['granted'] as bool?) != true) return;

      await DeviceCalendarService.instance.createEventForTask(
        calendarId: calId,
        title: task.title,
        notes: task.description,
        startAt: task.dueAt!,
      );
    } catch (e) {
      debugPrint('createEventForTask mirror skipped: $e');
    }
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
