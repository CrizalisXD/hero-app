import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';

class CreateHabitInput {
  const CreateHabitInput({
    required this.title,
    this.description,
    this.goalId,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = TaskDifficulty.normal,
    this.duration = TaskDuration.medium,
    this.importance = TaskImportance.normal,
    required this.xpReward,
    required this.disciplineXpReward,
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

  Map<String, dynamic> toInsertBody({required String userId}) {
    return {
      'user_id': userId,
      'goal_id': goalId,
      'title': title.trim(),
      if (description != null && description!.trim().isNotEmpty)
        'description': description!.trim(),
      'type': 'good',
      'input_type': 'boolean',
      'recurrence': 'daily',
      'target_value': 1,
      'main_category': mainCategory.wire,
      'secondary_categories': secondaryCategories.map((e) => e.wire).toList(),
      'difficulty': difficulty.wire,
      'duration': duration.wire,
      'importance': importance.wire,
      'xp_reward': xpReward,
      'discipline_xp_reward': disciplineXpReward,
    };
  }
}
