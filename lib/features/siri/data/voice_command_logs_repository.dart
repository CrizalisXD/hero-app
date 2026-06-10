import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// Audit log of every voice command (TZ §16 critical rule).
/// Errors during logging are swallowed — never let logging failures
/// break the user-visible action.
class VoiceCommandLogsRepository {
  VoiceCommandLogsRepository(this._client);
  final SupabaseClient _client;

  Future<void> log({
    required String intentName,
    String? transcript,
    required String status,
    Map<String, dynamic>? resultPayload,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return; // can't audit anonymous calls
    try {
      await _client.from('voice_command_logs').insert({
        'user_id': uid,
        'platform': 'siri',
        'intent_name': intentName,
        'transcript': transcript,
        'status': status,
        'result_payload': resultPayload ?? <String, dynamic>{},
      });
    } catch (_) {
      // Audit is best-effort.
    }
  }
}

final voiceCommandLogsRepositoryProvider =
    Provider<VoiceCommandLogsRepository>(
  (ref) => VoiceCommandLogsRepository(ref.watch(supabaseClientProvider)),
);
