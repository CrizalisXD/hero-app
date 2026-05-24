import '../../../categories/domain/models/category_id.dart';

enum AiSuggestionType { task, habit }

class AiSuggestion {
  const AiSuggestion({
    required this.type,
    required this.title,
    required this.mainCategory,
  });

  final AiSuggestionType type;
  final String title;
  final CategoryId mainCategory;

  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    final raw = json['type'] as String? ?? 'task';
    final type = raw == 'habit' ? AiSuggestionType.habit : AiSuggestionType.task;
    final cat =
        CategoryId.fromWire(json['main_category'] as String?) ?? CategoryId.mind;
    return AiSuggestion(
      type: type,
      title: (json['title'] as String? ?? '').trim(),
      mainCategory: cat,
    );
  }
}
