/// How the goal's plan is built:
/// - [ai]    — AI generates the full plan.
/// - [own]   — user builds every step by hand (no AI call).
/// - [mixed] — AI generates a plan the user can add their own steps to.
///
/// Unknown / legacy wire values resolve to [GoalPlanMode.ai].
enum GoalPlanMode {
  ai('ai'),
  own('own'),
  mixed('mixed');

  const GoalPlanMode(this.wire);

  final String wire;

  static GoalPlanMode fromWire(String? raw) {
    return GoalPlanMode.values.firstWhere(
      (e) => e.wire == raw,
      orElse: () => GoalPlanMode.ai,
    );
  }
}
