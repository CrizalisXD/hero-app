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
    // "Today" = every pending task whose due_at falls on today's calendar
    // date (in the user's local timezone) OR earlier — so overdue tasks
    // also surface here. Tasks without due_at stay only in the All tab.
    //
    // Bug we're fixing: prior version filtered `due_at <= now()` which
    // hid same-day tasks scheduled later in the day (created at 14:39
    // for 17:30 → not "due yet" → silently dropped from Today).
    final now = DateTime.now();
    final tomorrowMidnightLocal = DateTime(now.year, now.month, now.day + 1);
    final iso = tomorrowMidnightLocal.toUtc().toIso8601String();
    final rows = await _client
        .from('tasks')
        .select()
        .eq('user_id', _userId)
        .eq('is_done', false)
        .not('due_at', 'is', null)
        .lt('due_at', iso)
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

      final eventId = await DeviceCalendarService.instance.createEventForTask(
        calendarId: calId,
        title: task.title,
        notes: task.description,
        startAt: task.dueAt!,
      );

      // Persist the calendar event id so CalendarSyncAgent can detect
      // deletions on the OS side. Best-effort — failure here just leaves
      // the column NULL (sync still works for new events going forward).
      if (eventId != null) {
        try {
          await _client
              .from('tasks')
              .update({'external_calendar_event_id': eventId})
              .eq('id', task.id);
        } catch (e) {
          debugPrint('save external_calendar_event_id failed: $e');
        }
      }
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
    final updated = Task.fromJson(row);

    // Hero → Calendar outgoing edit sync. If the task is mirrored,
    // push the new title/start back to the calendar event so both
    // surfaces stay in agreement until the next reconcile.
    if (updated.externalCalendarEventId != null && updated.dueAt != null) {
      unawaited(_pushUpdateToCalendar(updated));
    }
    return updated;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    // Look up the task first so we can also drop its calendar event,
    // if it was mirrored. RLS keeps this safe — the SELECT only returns
    // the row when it belongs to the current user.
    String? eventId;
    try {
      final row = await _client
          .from('tasks')
          .select('external_calendar_event_id')
          .eq('id', taskId)
          .maybeSingle();
      eventId = row?['external_calendar_event_id'] as String?;
    } catch (_) {
      // If the lookup fails we still want to delete the task — just
      // skip the calendar side.
    }

    await _client.from('tasks').delete().eq('id', taskId);

    if (eventId != null) {
      unawaited(_dropCalendarEvent(eventId));
    }
  }

  Future<void> _pushUpdateToCalendar(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calId = prefs.getString('cal_default_id');
      if (calId == null) return;
      // createOrUpdateEvent updates in-place when eventId is provided.
      await DeviceCalendarService.instance.updateEventForTask(
        calendarId: calId,
        eventId: task.externalCalendarEventId!,
        title: task.title,
        notes: task.description,
        startAt: task.dueAt!,
      );
    } catch (e) {
      debugPrint('push calendar update skipped: $e');
    }
  }

  Future<void> _dropCalendarEvent(String eventId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final calId = prefs.getString('cal_default_id');
      if (calId == null) return;
      await DeviceCalendarService.instance.deleteEvent(calId, eventId);
    } catch (e) {
      debugPrint('drop calendar event skipped: $e');
    }
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return SupabaseTasksRepository(Supabase.instance.client);
});
