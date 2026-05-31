/// Row from `list_friends_feed` RPC.
/// `payload` is opaque JSON that depends on `titleKey` — UI dispatches
/// per known title_key (feedAchievementUnlocked, feedLevelUp, …).
class FeedEvent {
  const FeedEvent({
    required this.eventId,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.eventType,
    required this.titleKey,
    required this.payload,
    required this.createdAt,
  });

  final String eventId;
  final String userId;
  final String username;
  final String displayName;
  final String eventType;
  final String titleKey;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  factory FeedEvent.fromJson(Map<String, dynamic> j) => FeedEvent(
        eventId: j['event_id'] as String,
        userId: j['user_id'] as String,
        username: j['username'] as String? ?? '',
        displayName: j['display_name'] as String? ?? 'Hero',
        eventType: j['event_type'] as String,
        titleKey: j['title_key'] as String,
        payload:
            (j['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
