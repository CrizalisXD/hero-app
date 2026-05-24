/// Returned by `ai-goal-confirm` → `create_goal_with_plan` RPC.
class GoalConfirmResult {
  const GoalConfirmResult({
    required this.goalId,
    required this.tasksInserted,
    required this.habitsInserted,
    required this.milestonesInserted,
  });

  final String goalId;
  final int tasksInserted;
  final int habitsInserted;
  final int milestonesInserted;

  factory GoalConfirmResult.fromJson(Map<String, dynamic> j) {
    final inserted = (j['inserted'] as Map<String, dynamic>?) ?? {};
    return GoalConfirmResult(
      goalId: j['goal_id'] as String,
      tasksInserted: (inserted['tasks'] as num?)?.toInt() ?? 0,
      habitsInserted: (inserted['habits'] as num?)?.toInt() ?? 0,
      milestonesInserted: (inserted['milestones'] as num?)?.toInt() ?? 0,
    );
  }
}
