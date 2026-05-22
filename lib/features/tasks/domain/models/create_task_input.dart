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

  Map<String, dynamic> toInsertBody({required String userId}) {
    // dueAt is the canonical field; back-fill due_date (date) from it too.
    final effectiveDueDate = dueAt?.toIso8601String().split('T').first
        ?? dueDate?.toIso8601String().split('T').first;
    return {
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
      'due_date': effectiveDueDate,
      'due_at': dueAt?.toUtc().toIso8601String(),
      'is_recurring': isRecurring,
      'recurrence': isRecurring ? 'daily' : null,
    };
  }
}
