/// Реплика в обсуждении у канонической мечты.
///
/// Висит на самой мечте, а не на чьей-то копии — иначе советы «берите тандем
/// с видео» рассыпались бы по тысяче личных списков и никто бы их не увидел.
class DreamComment {
  const DreamComment({
    required this.id,
    required this.dreamId,
    required this.userId,
    required this.body,
    required this.createdAt,
    this.authorName,
    this.authorAvatarUrl,
    this.authorWorthRating,
  });

  final String id;
  final String dreamId;
  final String userId;
  final String body;
  final DateTime createdAt;

  final String? authorName;
  final String? authorAvatarUrl;

  /// Оценка «стоило того» от автора реплики, если он эту мечту сделал.
  /// Именно она отличает совет прошедшего путь от мнения зрителя.
  final int? authorWorthRating;

  bool get isFromDoer => authorWorthRating != null;

  factory DreamComment.fromJson(Map<String, dynamic> j) {
    final author = j['users'] as Map<String, dynamic>?;
    return DreamComment(
      id: j['id'] as String,
      dreamId: j['dream_id'] as String,
      userId: j['user_id'] as String,
      body: j['body'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
      authorName: author?['display_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
      authorWorthRating: (j['author_worth_rating'] as num?)?.toInt(),
    );
  }
}
