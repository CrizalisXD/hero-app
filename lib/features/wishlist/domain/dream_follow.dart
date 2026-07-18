/// Связь человека с мечтой: «я тоже хочу».
///
/// Сюда переехал прежний `WishlistItem`. Всё личное — здесь, и по умолчанию
/// приватно ([isPublic] = false): попасть в список «кто уже сделал» можно
/// только явно открывшись.
class DreamFollow {
  const DreamFollow({
    required this.id,
    required this.dreamId,
    required this.isPublic,
    required this.createdAt,
    this.doneAt,
    this.worthRating,
    this.note,
    this.photoUrl,
    this.convertedGoalId,
    this.convertedTaskId,
  });

  final String id;
  final String dreamId;

  /// Показывать ли меня другим в «кто уже сделал».
  final bool isPublic;

  final DateTime? doneAt;

  /// «Стоило того», 1..5. Ставится только когда [doneAt] проставлен —
  /// это правило держит БД, а не только UI.
  final int? worthRating;

  final String? note;
  final String? photoUrl;

  /// Мечта надумана и уехала в цель — там её декомпозируют на этапы.
  final String? convertedGoalId;
  final String? convertedTaskId;

  final DateTime createdAt;

  bool get isDone => doneAt != null;
  bool get isConverted => convertedGoalId != null || convertedTaskId != null;

  /// Оценить опыт можно только после того, как сделал.
  bool get canRateWorth => isDone;

  factory DreamFollow.fromJson(Map<String, dynamic> j) => DreamFollow(
        id: j['id'] as String,
        dreamId: j['dream_id'] as String,
        isPublic: (j['is_public'] as bool?) ?? false,
        doneAt: j['done_at'] == null
            ? null
            : DateTime.parse(j['done_at'] as String),
        worthRating: (j['worth_rating'] as num?)?.toInt(),
        note: j['note'] as String?,
        photoUrl: j['photo_url'] as String?,
        convertedGoalId: j['converted_goal_id'] as String?,
        convertedTaskId: j['converted_task_id'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  DreamFollow copyWith({
    bool? isPublic,
    DateTime? doneAt,
    int? worthRating,
    String? note,
    bool clearDone = false,
  }) =>
      DreamFollow(
        id: id,
        dreamId: dreamId,
        isPublic: isPublic ?? this.isPublic,
        doneAt: clearDone ? null : (doneAt ?? this.doneAt),
        // Снятие отметки «сделал» обязано снять и оценку: иначе останется
        // worth без done, что БД отвергнет через ck_worth_requires_done.
        worthRating: clearDone ? null : (worthRating ?? this.worthRating),
        note: note ?? this.note,
        photoUrl: photoUrl,
        convertedGoalId: convertedGoalId,
        convertedTaskId: convertedTaskId,
        createdAt: createdAt,
      );
}
