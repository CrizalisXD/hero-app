import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Thin client over the 4 account-lifecycle RPCs from migration 0005:
///   - request_account_deletion / cancel_account_deletion
///   - export_my_data
///   - clear_ai_memory
class AccountLifecycleRepository {
  AccountLifecycleRepository(this._client);
  final SupabaseClient _client;

  Map<String, dynamic> _toMap(dynamic res) =>
      res is Map ? Map<String, dynamic>.from(res) : <String, dynamic>{};

  Future<DateTime> requestDeletion({String? reason}) async {
    final res = await _client.rpc<dynamic>(
      'request_account_deletion',
      params: {'p_reason': reason},
    );
    final data = _toMap(res);
    return DateTime.parse(data['scheduled_deletion_at'] as String);
  }

  Future<bool> cancelDeletion() async {
    final res = await _client.rpc<dynamic>('cancel_account_deletion');
    final data = _toMap(res);
    return (data['was_scheduled'] as bool?) ?? false;
  }

  Future<Map<String, dynamic>> exportMyData() async {
    final res = await _client.rpc<dynamic>('export_my_data');
    return _toMap(res);
  }

  Future<int> clearAiMemory() async {
    final res = await _client.rpc<dynamic>('clear_ai_memory');
    final data = _toMap(res);
    return (data['deleted'] as num?)?.toInt() ?? 0;
  }
}

final accountLifecycleRepoProvider = Provider<AccountLifecycleRepository>(
  (ref) => AccountLifecycleRepository(ref.watch(supabaseClientProvider)),
);
