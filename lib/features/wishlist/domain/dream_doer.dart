/// Человек, который эту мечту уже сделал, и его след: оценка, заметка, фото.
///
/// Попадают сюда только те, кто сам открылся (`dream_follows.is_public`).
/// Список отдаёт RPC `list_dream_doers`, а не прямой запрос: RLS-политика
/// не умеет спросить `is_blocked_between`, поэтому заблокированный человек
/// иначе всё равно бы здесь светился.
class DreamDoer {
  const DreamDoer({
    required this.userId,
    required this.displayName,
    required this.doneAt,
    this.avatarUrl,
    this.worthRating,
    this.note,
    this.photoUrl,
  });

  final String userId;
  final String displayName;
  final String? avatarUrl;

  /// «Стоило того», 1..5.
  final int? worthRating;

  final String? note;
  final String? photoUrl;
  final DateTime doneAt;

  factory DreamDoer.fromJson(Map<String, dynamic> j) => DreamDoer(
        userId: j['user_id'] as String,
        displayName: (j['display_name'] as String?) ?? 'Hero',
        avatarUrl: j['avatar_preview_url'] as String?,
        worthRating: (j['worth_rating'] as num?)?.toInt(),
        note: j['note'] as String?,
        photoUrl: j['photo_url'] as String?,
        doneAt: DateTime.parse(j['done_at'] as String),
      );
}
