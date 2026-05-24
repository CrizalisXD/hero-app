import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/ai_chat_repository.dart';
import '../domain/models/ai_chat_send_result.dart';
import '../domain/models/ai_conversation.dart';
import '../domain/models/ai_message.dart';
import '../domain/models/ai_suggestion.dart';

class SupabaseAiChatRepository implements AiChatRepository {
  SupabaseAiChatRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<AiConversation?> getOrCreateActive() async {
    final rows = await _client
        .from('ai_conversations')
        .select()
        .eq('is_archived', false)
        .order('updated_at', ascending: false)
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return AiConversation.fromJson(rows.first as Map<String, dynamic>); // ignore: unnecessary_cast
  }

  @override
  Future<List<AiMessage>> listMessages(String conversationId) async {
    final rows = await _client
        .from('ai_messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return (rows as List)
        .map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AiChatSendResult> sendMessage({
    String? conversationId,
    required String text,
    required String locale,
  }) async {
    final res = await _client.functions.invoke(
      'ai-chat',
      body: {
        if (conversationId != null) 'conversation_id': conversationId,
        'message': text,
        'locale': locale,
      },
    );
    if (res.status == 429) {
      throw const AiChatDailyLimitException();
    }
    if (res.status != 200) {
      throw StateError('ai-chat http_${res.status}: ${res.data}');
    }
    final data = res.data;
    if (data is! Map<String, dynamic> || data['ok'] != true) {
      final errorMsg = data is Map ? data['error'] : data;
      throw StateError('ai-chat rejected: $errorMsg');
    }

    final convId = data['conversation_id'] as String;
    final userMsgJson = data['user_message'] as Map<String, dynamic>;
    final asstMsgJson = data['assistant_message'] as Map<String, dynamic>;
    final sugJson = data['suggestion'] as Map<String, dynamic>?;

    final userMsg = AiMessage(
      id: userMsgJson['id'] as String,
      conversationId: convId,
      role: AiMessageRole.user,
      content: text,
      createdAt: DateTime.parse(userMsgJson['created_at'] as String),
    );
    final asstMsg = AiMessage(
      id: asstMsgJson['id'] as String,
      conversationId: convId,
      role: AiMessageRole.assistant,
      content: asstMsgJson['content'] as String,
      suggestion: sugJson == null ? null : AiSuggestion.fromJson(sugJson),
      createdAt: DateTime.parse(asstMsgJson['created_at'] as String),
    );

    return AiChatSendResult(
      conversationId: convId,
      userMessage: userMsg,
      assistantMessage: asstMsg,
      suggestion: sugJson == null ? null : AiSuggestion.fromJson(sugJson),
    );
  }
}

final aiChatRepositoryProvider = Provider<AiChatRepository>((ref) {
  return SupabaseAiChatRepository(ref.watch(supabaseClientProvider));
});
