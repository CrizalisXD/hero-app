enum AiPlanStepType { task, habit, milestone }

AiPlanStepType _parseType(String? s) => switch (s) {
      'habit' => AiPlanStepType.habit,
      'milestone' => AiPlanStepType.milestone,
      _ => AiPlanStepType.task,
    };

class AiPlanStep {
  const AiPlanStep({
    required this.type,
    required this.title,
    this.description,
    this.mainCategory,
    this.secondaryCategories = const [],
    this.difficulty = 'normal',
    this.duration = 'medium',
    this.importance = 'normal',
    this.xpReward = 20,
    this.disciplineXpReward = 0,
    // task-only
    this.dueDaysFromNow,
    // habit-only
    this.frequency,
    // milestone-only
    this.targetDaysFromNow,
    this.enabled = true,
  });

  final AiPlanStepType type;
  final String title;
  final String? description;
  final String? mainCategory;
  final List<String> secondaryCategories;
  final String difficulty;
  final String duration;
  final String importance;
  final int xpReward;
  final int disciplineXpReward;
  final int? dueDaysFromNow;
  final String? frequency;
  final int? targetDaysFromNow;
  final bool enabled;

  factory AiPlanStep.fromJson(Map<String, dynamic> j) {
    final rawSecondaries =
        (j['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? [];
    return AiPlanStep(
      type: _parseType(j['type'] as String?),
      title: (j['title'] as String?) ?? '',
      description: j['description'] as String?,
      mainCategory: j['main_category'] as String?,
      secondaryCategories: rawSecondaries,
      difficulty: (j['difficulty'] as String?) ?? 'normal',
      duration: (j['duration'] as String?) ?? 'medium',
      importance: (j['importance'] as String?) ?? 'normal',
      xpReward: (j['xp_reward'] as num?)?.toInt() ?? 20,
      disciplineXpReward: (j['discipline_xp_reward'] as num?)?.toInt() ?? 0,
      dueDaysFromNow: (j['due_days_from_now'] as num?)?.toInt(),
      frequency: j['frequency'] as String?,
      targetDaysFromNow: (j['target_days_from_now'] as num?)?.toInt(),
      enabled: j['enabled'] as bool? ?? true,
    );
  }

  /// Serialises the step back to JSON for the `ai-goal-confirm` Edge Function.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type.name,
      'title': title,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (mainCategory != null) 'main_category': mainCategory,
      'secondary_categories': secondaryCategories,
      'difficulty': difficulty,
      'duration': duration,
      'importance': importance,
      'xp_reward': xpReward,
      'discipline_xp_reward': disciplineXpReward,
      'enabled': enabled,
      if (dueDaysFromNow != null) 'due_days_from_now': dueDaysFromNow,
      if (frequency != null) 'frequency': frequency,
      if (targetDaysFromNow != null) 'target_days_from_now': targetDaysFromNow,
    };
  }

  AiPlanStep copyWith({bool? enabled}) => AiPlanStep(
        type: type,
        title: title,
        description: description,
        mainCategory: mainCategory,
        secondaryCategories: secondaryCategories,
        difficulty: difficulty,
        duration: duration,
        importance: importance,
        xpReward: xpReward,
        disciplineXpReward: disciplineXpReward,
        dueDaysFromNow: dueDaysFromNow,
        frequency: frequency,
        targetDaysFromNow: targetDaysFromNow,
        enabled: enabled ?? this.enabled,
      );
}
