/// Aggregated progress counters for a single goal.
/// Returned by the `goal_progress_me` RPC.
class GoalProgress {
  const GoalProgress({
    required this.goalId,
    required this.tasksDone,
    required this.tasksTotal,
    required this.milestonesDone,
    required this.milestonesTotal,
  });

  final String goalId;
  final int tasksDone;
  final int tasksTotal;
  final int milestonesDone;
  final int milestonesTotal;

  factory GoalProgress.fromJson(Map<String, dynamic> j) => GoalProgress(
        goalId: j['goal_id'] as String,
        tasksDone: (j['tasks_done'] as num?)?.toInt() ?? 0,
        tasksTotal: (j['tasks_total'] as num?)?.toInt() ?? 0,
        milestonesDone: (j['milestones_done'] as num?)?.toInt() ?? 0,
        milestonesTotal: (j['milestones_total'] as num?)?.toInt() ?? 0,
      );

  double get taskPercent =>
      tasksTotal == 0 ? 0 : tasksDone / tasksTotal;

  /// Alias for [taskPercent] — used by ActiveGoalPanel.
  double get taskProgress => taskPercent;

  double get milestonePercent =>
      milestonesTotal == 0 ? 0 : milestonesDone / milestonesTotal;
}
