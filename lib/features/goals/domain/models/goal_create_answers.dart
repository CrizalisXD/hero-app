/// User answers from the GoalCreateScreen.
/// Serialises to the payload expected by `ai-goal-decompose`.
class GoalCreateAnswers {
  const GoalCreateAnswers({
    required this.title,
    this.description,
    required this.deadlineDays,
    required this.minutesPerDay,
    required this.currentLevel,
    required this.hasMaterials,
  });

  final String title;
  final String? description;

  /// Calendar days until the desired completion date (e.g. 7 / 30 / 90).
  final int deadlineDays;

  /// Minutes the user is willing to spend per day.
  final int minutesPerDay;

  /// 'beginner' | 'intermediate' | 'advanced'
  final String currentLevel;

  final bool hasMaterials;

  Map<String, dynamic> toDecomposePayload({String locale = 'ru'}) => {
        'goal_title': title,
        if (description != null && description!.isNotEmpty)
          'goal_description': description,
        'locale': locale,
        'answers': {
          'current_level': currentLevel,
          'deadline_days': deadlineDays,
          'minutes_per_day': minutesPerDay,
          'has_materials': hasMaterials,
        },
      };
}
