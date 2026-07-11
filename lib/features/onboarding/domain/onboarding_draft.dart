class OnboardingDraft {
  const OnboardingDraft({
    this.displayName = '',
    this.lifeChangeAreas = const [],
    this.mainObstacles = const [],
    this.energyLevel = 3,
    this.timeCommitmentMinutes = 15,
    this.preferredTime = '',
    this.failureReasons = const [],
    this.supportStyle = '',
    this.starterHabits = const [],
  });

  final String displayName;
  final List<String> lifeChangeAreas;
  /// Мультивыбор; в API уходит склейкой в текстовое main_obstacle.
  final List<String> mainObstacles;
  final int energyLevel;
  final int timeCommitmentMinutes;

  /// 'morning' | 'afternoon' | 'evening' — дефолт для напоминаний привычек.
  final String preferredTime;
  final List<String> failureReasons;
  final String supportStyle;
  final List<String> starterHabits;

  OnboardingDraft copyWith({
    String? displayName,
    List<String>? lifeChangeAreas,
    List<String>? mainObstacles,
    int? energyLevel,
    int? timeCommitmentMinutes,
    String? preferredTime,
    List<String>? failureReasons,
    String? supportStyle,
    List<String>? starterHabits,
  }) {
    return OnboardingDraft(
      displayName: displayName ?? this.displayName,
      lifeChangeAreas: lifeChangeAreas ?? this.lifeChangeAreas,
      mainObstacles: mainObstacles ?? this.mainObstacles,
      energyLevel: energyLevel ?? this.energyLevel,
      timeCommitmentMinutes:
          timeCommitmentMinutes ?? this.timeCommitmentMinutes,
      preferredTime: preferredTime ?? this.preferredTime,
      failureReasons: failureReasons ?? this.failureReasons,
      supportStyle: supportStyle ?? this.supportStyle,
      starterHabits: starterHabits ?? this.starterHabits,
    );
  }

  Map<String, dynamic> toJson() => {
        'display_name': displayName,
        'life_change_areas': lifeChangeAreas,
        'main_obstacle': mainObstacles.join(', '),
        'energy_level': energyLevel,
        'time_commitment_minutes': timeCommitmentMinutes,
        'preferred_time': preferredTime,
        'failure_reasons': failureReasons,
        'support_style': supportStyle,
        'starter_habits': starterHabits,
      };
}
