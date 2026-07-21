import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/habits_repository.dart';
import '../domain/models/create_habit_input.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_checkin_result.dart';

class SupabaseHabitsRepository implements HabitsRepository {
  SupabaseHabitsRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  /// Returns ISO date string for today in local time (YYYY-MM-DD).
  String _isoToday() {
    final d = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  @override
  Future<List<Habit>> listActive() async {
    final rows = await _client
        .from('habits')
        .select()
        .eq('user_id', _uid)
        .eq('is_archived', false)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Habit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Set<String>> habitIdsCheckedToday() async {
    final rows = await _client
        .from('habit_logs')
        .select('habit_id')
        .eq('user_id', _uid)
        .eq('log_date', _isoToday());
    return (rows as List)
        .map((e) => (e as Map<String, dynamic>)['habit_id'] as String)
        .toSet();
  }

  @override
  Future<Habit> create(CreateHabitInput input) async {
    final body = input.toInsertBody(userId: _uid);
    final row = await _client.from('habits').insert(body).select().single();
    return Habit.fromJson(row);
  }

  @override
  Future<Habit> update(
    String habitId, {
    required String title,
    String? description,
  }) async {
    final row = await _client
        .from('habits')
        .update({'title': title, 'description': description})
        .eq('id', habitId)
        .eq('user_id', _uid)
        .select()
        .single();
    return Habit.fromJson(row);
  }

  @override
  Future<HabitCheckinResult> checkin(String habitId) async {
    late final dynamic raw;
    try {
      raw = await _client.rpc<dynamic>(
        'complete_habit_checkin',
        params: {'p_habit_id': habitId, 'p_value': 1},
      );
    } on PostgrestException catch (e) {
      debugPrint(
        'complete_habit_checkin PostgrestException: '
        '${e.code} | ${e.message} | ${e.details}',
      );
      rethrow;
    }

    final Map<String, dynamic> map;
    if (raw is Map) {
      map = Map<String, dynamic>.from(raw);
    } else if (raw is String) {
      map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } else if (raw is List && raw.isNotEmpty && raw.first is Map) {
      map = Map<String, dynamic>.from(raw.first as Map);
    } else {
      throw StateError(
        'complete_habit_checkin: unexpected payload '
        '${raw.runtimeType}: $raw',
      );
    }

    if (map['ok'] != true) {
      throw StateError(
        'complete_habit_checkin rejected: ${map['error'] ?? map}',
      );
    }
    return HabitCheckinResult.fromRpc(map);
  }

  @override
  Future<void> archive(String habitId) async {
    await _client
        .from('habits')
        .update({'is_archived': true})
        .eq('id', habitId)
        .eq('user_id', _uid);
  }

  @override
  Future<void> uncheckin(String habitId) async {
    await _client.rpc<dynamic>(
      'uncomplete_habit_checkin',
      params: {'p_habit_id': habitId},
    );
  }

  @override
  Future<void> skipToday(String habitId) async {
    await _client.rpc<dynamic>(
      'skip_habit_today',
      params: {'p_habit_id': habitId},
    );
  }

  @override
  Future<void> delete(String habitId) async {
    await _client
        .from('habits')
        .delete()
        .eq('id', habitId)
        .eq('user_id', _uid);
  }
}

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseHabitsRepository(client);
});
