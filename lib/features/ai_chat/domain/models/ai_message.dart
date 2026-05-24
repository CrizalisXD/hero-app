import 'ai_suggestion.dart';

enum AiMessageRole { user, assistant, system }

class AiMessage {
  const AiMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.suggestion,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final AiMessageRole role;
  final String content;
  final AiSuggestion? suggestion;
  final DateTime createdAt;

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    final meta = (json['metadata'] as Map<String, dynamic>?) ?? const {};
    final sug = meta['suggestion'] as Map<String, dynamic>?;
    return AiMessage(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: switch (json['role'] as String?) {
        'user' => AiMessageRole.user,
        'assistant' => AiMessageRole.assistant,
        _ => AiMessageRole.system,
      },
      content: json['content'] as String? ?? '',
      suggestion: sug == null ? null : AiSuggestion.fromJson(sug),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
