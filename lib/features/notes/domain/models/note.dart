import 'note_visibility.dart';

class Note {
  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String? title;
  final String content;
  final NoteVisibility visibility;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Note.fromJson(Map<String, dynamic> j) {
    return Note(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      title: j['title'] as String?,
      content: (j['content'] as String?) ?? '',
      visibility: NoteVisibility.fromWire(j['visibility'] as String?),
      createdAt: DateTime.parse(j['created_at'] as String),
      updatedAt: DateTime.parse(j['updated_at'] as String),
    );
  }

  Note copyWith({
    String? title,
    String? content,
    NoteVisibility? visibility,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      visibility: visibility ?? this.visibility,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Input for creating / updating a note. Title is optional; content is
/// required. Visibility defaults to private — explicit opt-in to AI sharing.
class NoteInput {
  const NoteInput({
    this.title,
    required this.content,
    this.visibility = NoteVisibility.private,
  });

  final String? title;
  final String content;
  final NoteVisibility visibility;

  Map<String, dynamic> toInsertBody({required String userId}) => {
        'user_id': userId,
        if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
        'content': content,
        'visibility': visibility.wire,
      };

  Map<String, dynamic> toUpdateBody() => {
        'title': (title != null && title!.trim().isNotEmpty) ? title!.trim() : null,
        'content': content,
        'visibility': visibility.wire,
      };
}
