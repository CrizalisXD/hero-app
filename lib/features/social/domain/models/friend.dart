/// Row from `list_my_friends` RPC.
class Friend {
  const Friend({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarPreviewUrl,
    required this.publicLevel,
    required this.friendshipCreatedAt,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? avatarPreviewUrl;
  final int publicLevel;
  final DateTime friendshipCreatedAt;

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
        userId: j['friend_user_id'] as String,
        username: j['username'] as String? ?? '',
        displayName: j['display_name'] as String? ?? 'Hero',
        avatarPreviewUrl: j['avatar_preview_url'] as String?,
        publicLevel: (j['public_level'] as num?)?.toInt() ?? 1,
        friendshipCreatedAt:
            DateTime.parse(j['friendship_created_at'] as String),
      );
}
