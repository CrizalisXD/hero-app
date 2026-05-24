import 'ai_message.dart';
import 'ai_suggestion.dart';

class AiChatSendResult {
  const AiChatSendResult({
    required this.conversationId,
    required this.userMessage,
    required this.assistantMessage,
    this.suggestion,
  });

  final String conversationId;
  final AiMessage userMessage;
  final AiMessage assistantMessage;
  final AiSuggestion? suggestion;
}
