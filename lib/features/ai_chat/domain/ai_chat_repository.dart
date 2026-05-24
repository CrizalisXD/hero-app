import 'models/ai_chat_send_result.dart';
import 'models/ai_conversation.dart';
import 'models/ai_message.dart';

abstract class AiChatRepository {
  Future<AiConversation?> getOrCreateActive();
  Future<List<AiMessage>> listMessages(String conversationId);
  Future<AiChatSendResult> sendMessage({
    String? conversationId,
    required String text,
    required String locale,
  });
}

class AiChatDailyLimitException implements Exception {
  const AiChatDailyLimitException();
  @override
  String toString() => 'AiChatDailyLimitException';
}
