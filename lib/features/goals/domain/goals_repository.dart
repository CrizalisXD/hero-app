import 'models/ai_plan.dart';
import 'models/goal.dart';
import 'models/goal_confirm_result.dart';
import 'models/goal_create_answers.dart';
import 'models/goal_progress.dart';

abstract interface class GoalsRepository {
  /// Calls `ai-goal-decompose` Edge Function and returns the AI plan.
  Future<AiPlan> decomposePlan(GoalCreateAnswers answers);

  /// Calls `ai-goal-confirm` Edge Function → `create_goal_with_plan` RPC.
  Future<GoalConfirmResult> confirmPlan({
    required AiPlan plan,
    required String goalTitle,
    String? goalDescription,
  });

  /// Loads all non-deleted goals for the current user.
  Future<List<Goal>> fetchGoals();

  /// Loads aggregated progress for all goals belonging to the current user.
  Future<List<GoalProgress>> fetchProgress();

  /// Progress for a single goal (filtered from fetchProgress).
  Future<GoalProgress?> progressOf(String goalId);
}
