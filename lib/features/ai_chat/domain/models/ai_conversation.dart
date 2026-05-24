class AiConversation {
  const AiConversation({
    required this.id,
    required this.contextType,
    required this.createdAt,
  });

  final String id;
  final String contextType;
  final DateTime createdAt;

  factory AiConversation.fromJson(Map<String, dynamic> json) => AiConversation(
        id: json['id'] as String,
        contextType: json['context_type'] as String? ?? 'general',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
