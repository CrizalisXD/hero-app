class OnboardingDraft {
  const OnboardingDraft({
    this.lifeChangeAreas = const [],
    this.mainObstacle = '',
    this.energyLevel = 3,
    this.timeCommitmentMinutes = 15,
    this.failureReasons = const [],
    this.supportStyle = '',
    this.starterHabits = const [],
  });

  final List<String> lifeChangeAreas;
  final String mainObstacle;
  final int energyLevel;
  final int timeCommitmentMinutes;
  final List<String> failureReasons;
  final String supportStyle;
  final List<String> starterHabits;

  OnboardingDraft copyWith({
    List<String>? lifeChangeAreas,
    String? mainObstacle,
    int? energyLevel,
    int? timeCommitmentMinutes,
    List<String>? failureReasons,
    String? supportStyle,
    List<String>? starterHabits,
  }) {
    return OnboardingDraft(
      lifeChangeAreas: lifeChangeAreas ?? this.lifeChangeAreas,
      mainObstacle: mainObstacle ?? this.mainObstacle,
      energyLevel: energyLevel ?? this.energyLevel,
      timeCommitmentMinutes:
          timeCommitmentMinutes ?? this.timeCommitmentMinutes,
      failureReasons: failureReasons ?? this.failureReasons,
      supportStyle: supportStyle ?? this.supportStyle,
      starterHabits: starterHabits ?? this.starterHabits,
    );
  }

  Map<String, dynamic> toJson() => {
        'life_change_areas': lifeChangeAreas,
        'main_obstacle': mainObstacle,
        'energy_level': energyLevel,
        'time_commitment_minutes': timeCommitmentMinutes,
        'failure_reasons': failureReasons,
        'support_style': supportStyle,
        'starter_habits': starterHabits,
      };
}
