/// Reasons why the user typically quits their habits/goals.
///
/// [wireValue] is the exact string sent to the server.
enum FailureReason {
  loseMotivation,
  noTime,
  noStructure,
  tooHard,
  boredom,
  perfectionism;

  String get wireValue => switch (this) {
        FailureReason.loseMotivation => 'lose_motivation',
        FailureReason.noTime => 'no_time',
        FailureReason.noStructure => 'no_structure',
        FailureReason.tooHard => 'too_hard',
        FailureReason.boredom => 'boredom',
        FailureReason.perfectionism => 'perfectionism',
      };
}
