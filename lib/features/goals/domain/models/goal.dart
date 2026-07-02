import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';
import 'goal_archetype.dart';
import 'goal_plan_mode.dart';

enum GoalStatus { active, completed, paused, abandoned, extended }

GoalStatus _parseGoalStatus(String? s) => switch (s) {
      'completed' => GoalStatus.completed,
      'paused' => GoalStatus.paused,
      'abandoned' => GoalStatus.abandoned,
      'extended' => GoalStatus.extended,
      _ => GoalStatus.active,
    };

/// Immutable domain model for a goal.
/// Written manually (no Freezed) — build_runner is broken in this project.
class Goal {
  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = TaskDifficulty.normal,
    this.duration = TaskDuration.medium,
    this.importance = TaskImportance.normal,
    this.status = GoalStatus.active,
    this.targetDate,
    this.aiGenerated = false,
    this.isDeleted = false,
    this.archetype = GoalArchetype.custom,
    this.planMode = GoalPlanMode.ai,
    this.planPeriodDays = 30,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final CategoryId mainCategory;
  final List<CategoryId> secondaryCategories;
  final TaskDifficulty difficulty;
  final TaskDuration duration;
  final TaskImportance importance;
  final GoalStatus status;
  final DateTime? targetDate;
  final bool aiGenerated;
  final bool isDeleted;
  final GoalArchetype archetype;
  final GoalPlanMode planMode;
  final int planPeriodDays;
  final DateTime createdAt;

  factory Goal.fromJson(Map<String, dynamic> j) {
    final rawSecondaries =
        (j['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? [];
    return Goal(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      title: j['title'] as String,
      description: j['description'] as String?,
      mainCategory:
          CategoryId.fromWire(j['main_category'] as String?) ?? CategoryId.mind,
      secondaryCategories: rawSecondaries
          .map(CategoryId.fromWire)
          .whereType<CategoryId>()
          .toList(),
      difficulty: TaskDifficulty.fromWire(j['difficulty'] as String?),
      duration: TaskDuration.fromWire(j['duration'] as String?),
      importance: TaskImportance.fromWire(j['importance'] as String?),
      status: _parseGoalStatus(j['status'] as String?),
      targetDate: j['target_date'] == null
          ? null
          : DateTime.tryParse(j['target_date'] as String),
      aiGenerated: j['ai_generated'] as bool? ?? false,
      isDeleted: j['is_deleted'] as bool? ?? false,
      archetype: GoalArchetype.fromWire(j['archetype'] as String?),
      planMode: GoalPlanMode.fromWire(j['plan_mode'] as String?),
      planPeriodDays: (j['plan_period_days'] as num?)?.toInt() ?? 30,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}
