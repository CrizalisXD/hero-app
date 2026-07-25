import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/models/routine.dart';
import '../domain/models/routine_inputs.dart';

class SupabaseRoutinesRepository {
  SupabaseRoutinesRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  String _isoToday() {
    final d = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<List<Routine>> listActive() async {
    final rows = await _client
        .from('routines')
        .select('*, routine_steps(*)')
        .eq('user_id', _uid)
        .eq('is_archived', false)
        .order('sort_order');
    return (rows as List)
        .map((e) => Routine.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<Set<String>> completedTodayIds() async {
    final rows = await _client
        .from('routine_logs')
        .select('routine_id')
        .eq('user_id', _uid)
        .eq('log_date', _isoToday());
    return (rows as List)
        .map((e) => (e as Map)['routine_id'] as String)
        .toSet();
  }

  Future<Routine> create(RoutineInput input) async {
    final uid = _uid;
    final routineRow = await _client
        .from('routines')
        .insert({
          'user_id': uid,
          'title': input.title,
          'scheduled_time': input.scheduledTime,
          'reminder_enabled': input.reminderEnabled,
          'xp_reward': input.xpReward,
        })
        .select()
        .single();
    final id = routineRow['id'] as String;
    await _insertSteps(id, uid, input.steps);
    return _fetchOne(id);
  }

  Future<Routine> update(String id, RoutineInput input) async {
    final uid = _uid;
    await _client
        .from('routines')
        .update({
          'title': input.title,
          'scheduled_time': input.scheduledTime,
          'reminder_enabled': input.reminderEnabled,
        })
        .eq('id', id)
        .eq('user_id', uid);
    // Replace steps wholesale — simplest correct sync for an inline editor.
    await _client.from('routine_steps').delete().eq('routine_id', id);
    await _insertSteps(id, uid, input.steps);
    return _fetchOne(id);
  }

  Future<void> _insertSteps(
    String routineId,
    String uid,
    List<RoutineStepInput> steps,
  ) async {
    if (steps.isEmpty) return;
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < steps.length; i++) {
      rows.add({
        'routine_id': routineId,
        'user_id': uid,
        'title': steps[i].title,
        'duration_minutes': steps[i].durationMinutes,
        'sort_order': i,
      });
    }
    await _client.from('routine_steps').insert(rows);
  }

  Future<Routine> _fetchOne(String id) async {
    final row = await _client
        .from('routines')
        .select('*, routine_steps(*)')
        .eq('id', id)
        .single();
    return Routine.fromJson((row as Map).cast<String, dynamic>());
  }

  Future<void> delete(String id) async {
    await _client.from('routines').delete().eq('id', id).eq('user_id', _uid);
  }

  Future<RoutineCompletionResult> complete(String id) async {
    final res = await _client
        .rpc<dynamic>('complete_routine', params: {'p_routine_id': id});
    final map =
        res is Map ? Map<String, dynamic>.from(res) : const <String, dynamic>{};
    return RoutineCompletionResult.fromJson(map);
  }

  Future<void> uncomplete(String id) async {
    await _client
        .rpc<dynamic>('uncomplete_routine', params: {'p_routine_id': id});
  }
}

final routinesRepositoryProvider = Provider<SupabaseRoutinesRepository>(
  (ref) => SupabaseRoutinesRepository(ref.watch(supabaseClientProvider)),
);
