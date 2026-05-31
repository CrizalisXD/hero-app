/// Snapshot returned by `get_public_profile` RPC. All data here is safe
/// to show to anyone (no tasks/goals/AI/health leaked).
class PublicProfile {
  const PublicProfile({
    required this.userId,
    required this.username,
    required this.displayName,
    this.avatarPreviewUrl,
    this.publicTitle,
    required this.publicLevel,
    this.streak,
    required this.achievementsCount,
  });

  final String userId;
  final String username;
  final String displayName;
  final String? avatarPreviewUrl;
  final String? publicTitle;
  final int publicLevel;

  /// Null when the user disabled the `social_show_streak` consent.
  final int? streak;
  final int achievementsCount;

  factory PublicProfile.fromJson(Map<String, dynamic> j) => PublicProfile(
        userId: j['user_id'] as String,
        username: j['username'] as String? ?? '',
        displayName: j['display_name'] as String? ?? 'Hero',
        avatarPreviewUrl: j['avatar_preview_url'] as String?,
        publicTitle: j['public_title'] as String?,
        publicLevel: (j['public_level'] as num?)?.toInt() ?? 1,
        streak: (j['streak'] as num?)?.toInt(),
        achievementsCount: (j['achievements_count'] as num?)?.toInt() ?? 0,
      );
}
