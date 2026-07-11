/// Идея из бэклога «Хочу попробовать».
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.title,
    required this.createdAt,
    this.triedAt,
    this.convertedTaskId,
  });

  final String id;
  final String title;
  final DateTime createdAt;

  /// Проставлено — идея «попробована» (уходит в нижнюю секцию).
  final DateTime? triedAt;

  /// Идея превращена в задачу.
  final String? convertedTaskId;

  bool get isTried => triedAt != null;
  bool get isConverted => convertedTaskId != null;

  factory WishlistItem.fromJson(Map<String, dynamic> j) => WishlistItem(
        id: j['id'] as String,
        title: j['title'] as String,
        createdAt: DateTime.parse(j['created_at'] as String),
        triedAt: j['tried_at'] == null
            ? null
            : DateTime.parse(j['tried_at'] as String),
        convertedTaskId: j['converted_task_id'] as String?,
      );

  WishlistItem copyWith({
    DateTime? triedAt,
    String? convertedTaskId,
  }) =>
      WishlistItem(
        id: id,
        title: title,
        createdAt: createdAt,
        triedAt: triedAt ?? this.triedAt,
        convertedTaskId: convertedTaskId ?? this.convertedTaskId,
      );
}
