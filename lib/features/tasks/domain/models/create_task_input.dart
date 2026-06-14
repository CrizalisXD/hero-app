import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';

class CreateTaskInput {
  const CreateTaskInput({
    required this.title,
    this.description,
    this.goalId,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = TaskDifficulty.normal,
    this.duration = TaskDuration.medium,
    this.importance = TaskImportance.normal,
    required this.xpReward,
    this.disciplineXpReward = 0,
    this.dueDate,
    this.dueAt,
    this.isRecurring = false,
    this.recurrence,
  });

  final String title;
  final String? description;
  final String? goalId;
  final CategoryId mainCategory;
  final List<CategoryId> secondaryCategories;
  final TaskDifficulty difficulty;
  final TaskDuration duration;
  final TaskImportance importance;
  final int xpReward;
  final int disciplineXpReward;
  final DateTime? dueDate;
  /// Precision due datetime (timestamptz). Takes priority over [dueDate].
  final DateTime? dueAt;
  final bool isRecurring;
  /// 'daily' or 'weekly' when [isRecurring] is true.
  final String? recurrence;

  Map<String, dynamic> toInsertBody({required String userId}) {
    final body = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'description': description,
      'goal_id': goalId,
      'main_category': mainCategory.wire,
      'secondary_categories':
          secondaryCategories.map((e) => e.wire).toList(),
      'difficulty': difficulty.wire,
      'duration': duration.wire,
      'importance': importance.wire,
      'xp_reward': xpReward,
      'discipline_xp_reward': disciplineXpReward,
      'is_recurring': isRecurring,
      'recurrence': isRecurring ? (recurrence ?? 'daily') : null,
    };

    // Only include date/time fields when set — avoids "column does not exist"
    // errors if the migration hasn't been applied yet.
    if (dueAt != null) {
      body['due_at'] = dueAt!.toUtc().toIso8601String();
      body['due_date'] = dueAt!.toIso8601String().split('T').first;
    } else if (dueDate != null) {
      body['due_date'] = dueDate!.toIso8601String().split('T').first;
    }

    return body;
  }
}
