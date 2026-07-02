import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import 'entity_reminder.dart';

class ReminderRepository {
  ReminderRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<EntityReminder>> forEntity({
    required String entityType,
    required String entityId,
  }) async {
    final rows = await _client
        .from('entity_reminders')
        .select()
        .eq('user_id', _uid)
        .eq('entity_type', entityType)
        .eq('entity_id', entityId)
        .eq('is_active', true);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(EntityReminder.fromJson)
        .toList();
  }

  Future<EntityReminder> create(Map<String, dynamic> body) async {
    final row = await _client
        .from('entity_reminders')
        .insert({...body, 'user_id': _uid})
        .select()
        .single();
    return EntityReminder.fromJson(row);
  }

  Future<void> deactivate(String reminderId) async {
    await _client
        .from('entity_reminders')
        .update({'is_active': false})
        .eq('id', reminderId)
        .eq('user_id', _uid);
  }
}

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(ref.watch(supabaseClientProvider)),
);
