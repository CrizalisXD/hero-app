/// Row from `list_pending_requests` RPC. Always pending — accepted/declined
/// rows are filtered out server-side.
class FriendRequest {
  const FriendRequest({
    required this.requestId,
    required this.senderId,
    required this.senderUsername,
    required this.senderDisplayName,
    this.senderAvatarPreviewUrl,
    required this.createdAt,
  });

  final String requestId;
  final String senderId;
  final String senderUsername;
  final String senderDisplayName;
  final String? senderAvatarPreviewUrl;
  final DateTime createdAt;

  factory FriendRequest.fromJson(Map<String, dynamic> j) => FriendRequest(
        requestId: j['request_id'] as String,
        senderId: j['sender_id'] as String,
        senderUsername: j['sender_username'] as String? ?? '',
        senderDisplayName: j['sender_display_name'] as String? ?? 'Hero',
        senderAvatarPreviewUrl: j['sender_avatar_preview_url'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}
