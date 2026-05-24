import 'models/failure_reason.dart';
import 'models/life_area.dart';
import 'models/starter_habit_key.dart';
import 'models/support_style.dart';

/// In-memory onboarding questionnaire state.
///
/// Stored only in Riverpod — never persisted to SharedPreferences.
/// Serialised to the wire format via [toJson] right before the
/// `onboarding-bootstrap` Edge Function call.
class OnboardingDraft {
  const OnboardingDraft({
    this.lifeChangeAreas = const {},
    this.mainObstacle = '',
    this.energyLevel = 3,
    this.timeCommitmentMinutes = 15,
    this.failureReasons = const {},
    this.supportStyle,
    this.starterHabits = const {},
  });

  final Set<LifeArea> lifeChangeAreas;
  final String mainObstacle;
  final int energyLevel;
  final int timeCommitmentMinutes;
  final Set<FailureReason> failureReasons;

  /// Null until the user has made a selection.
  final SupportStyle? supportStyle;

  final Set<StarterHabitKey> starterHabits;

  OnboardingDraft copyWith({
    Set<LifeArea>? lifeChangeAreas,
    String? mainObstacle,
    int? energyLevel,
    int? timeCommitmentMinutes,
    Set<FailureReason>? failureReasons,
    SupportStyle? supportStyle,
    Set<StarterHabitKey>? starterHabits,
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

  /// Wire payload for the `onboarding-bootstrap` Edge Function.
  /// Wire values come exclusively from each enum's [wireValue] getter —
  /// no raw strings leak into the call site.
  Map<String, dynamic> toJson() => {
        'life_change_areas':
            lifeChangeAreas.map((a) => a.wireValue).toList(),
        'main_obstacle': mainObstacle,
        'energy_level': energyLevel,
        'time_commitment_minutes': timeCommitmentMinutes,
        'failure_reasons':
            failureReasons.map((r) => r.wireValue).toList(),
        'support_style':
            (supportStyle ?? SupportStyle.direct).wireValue,
        'starter_habits':
            starterHabits.map((h) => h.wireValue).toList(),
      };
}
