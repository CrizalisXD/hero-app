/// A step as entered in the editor (no id yet).
class RoutineStepInput {
  const RoutineStepInput({required this.title, this.durationMinutes});
  final String title;
  final int? durationMinutes;

  Map<String, dynamic> toJson() => {
        'title': title,
        'duration_minutes': durationMinutes,
      };
}

/// Payload for creating or updating a routine.
class RoutineInput {
  const RoutineInput({
    required this.title,
    required this.scheduledTime,
    required this.reminderEnabled,
    required this.steps,
    this.xpReward = 25,
  });

  final String title;

  /// "HH:mm" or null.
  final String? scheduledTime;
  final bool reminderEnabled;
  final int xpReward;
  final List<RoutineStepInput> steps;
}

/// Result of complete_routine.
class RoutineCompletionResult {
  const RoutineCompletionResult({
    required this.duplicate,
    required this.xpAwarded,
    required this.currentStreak,
    required this.levelsGained,
    required this.levelAfter,
  });

  final bool duplicate;
  final int xpAwarded;
  final int currentStreak;
  final int levelsGained;
  final int levelAfter;

  factory RoutineCompletionResult.fromJson(Map<String, dynamic> j) {
    final xp = j['xp_result'];
    final xpMap =
        xp is Map ? xp.cast<String, dynamic>() : const <String, dynamic>{};
    return RoutineCompletionResult(
      duplicate: j['duplicate'] as bool? ?? false,
      xpAwarded: (j['xp_awarded'] as num?)?.toInt() ?? 0,
      currentStreak: (j['current_streak'] as num?)?.toInt() ?? 0,
      levelsGained: (xpMap['levels_gained'] as num?)?.toInt() ?? 0,
      levelAfter: (xpMap['level_after'] as num?)?.toInt() ?? 0,
    );
  }
}
