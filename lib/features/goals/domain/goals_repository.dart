import 'models/ai_plan.dart';
import 'models/goal.dart';
import 'models/goal_confirm_result.dart';
import 'models/goal_create_answers.dart';
import 'models/goal_progress.dart';

abstract interface class GoalsRepository {
  /// Calls `ai-goal-decompose` Edge Function and returns the AI plan.
  Future<AiPlan> decomposePlan(GoalCreateAnswers answers);

  /// Calls `ai-goal-confirm` Edge Function → `create_goal_with_plan` RPC.
  /// The full [answers] are forwarded so the goal record carries its
  /// archetype, plan mode and period (target_date is derived from them).
  Future<GoalConfirmResult> confirmPlan({
    required AiPlan plan,
    required GoalCreateAnswers answers,
  });

  /// Loads all non-deleted goals for the current user.
  Future<List<Goal>> fetchGoals();

  /// Loads aggregated progress for all goals belonging to the current user.
  Future<List<GoalProgress>> fetchProgress();

  /// Progress for a single goal (filtered from fetchProgress).
  Future<GoalProgress?> progressOf(String goalId);

  /// Soft-deletes a goal. Sets is_deleted=true so it disappears from
  /// every list; child tasks/habits/milestones stay linked but the goal
  /// no longer surfaces.
  Future<void> deleteGoal(String goalId);

  /// Updates a goal's lifecycle status (active / paused / extended / …).
  Future<void> updateStatus(String goalId, GoalStatus status);

  /// Pushes a goal's target date out and marks it as extended.
  Future<void> extendGoal(String goalId, DateTime targetDate);
}
