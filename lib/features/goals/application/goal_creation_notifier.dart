import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_goals_repository.dart';
import '../domain/goals_repository.dart';
import '../domain/models/ai_plan.dart';
import '../domain/models/ai_plan_step.dart';
import '../domain/models/goal_confirm_result.dart';
import '../domain/models/goal_create_answers.dart';
import '../domain/models/goal_plan_mode.dart';

// ── Sealed state ─────────────────────────────────────────────────────────────

sealed class GoalCreationState {}

/// User is filling in the title/description form — nothing submitted yet.
final class GoalCreationIdle extends GoalCreationState {}

/// User entered a title and is now picking an archetype + plan params.
/// Holds only title/description (carried over from the first screen).
final class GoalCreationPickingArchetype extends GoalCreationState {
  GoalCreationPickingArchetype({
    required this.title,
    this.description,
  });
  final String title;
  final String? description;
}

/// Waiting for `ai-goal-decompose` response.
final class GoalCreationAnalyzing extends GoalCreationState {}

/// AI plan received (or empty plan for "own" mode); user is reviewing /
/// toggling / editing steps.
final class GoalCreationReview extends GoalCreationState {
  GoalCreationReview({
    required this.answers,
    required this.plan,
  });
  final GoalCreateAnswers answers;
  final AiPlan plan;
}

/// User confirmed — waiting for `ai-goal-confirm` to finish.
final class GoalCreationConfirming extends GoalCreationState {
  GoalCreationConfirming({required this.plan});
  final AiPlan plan;
}

/// All records created successfully.
final class GoalCreationDone extends GoalCreationState {
  GoalCreationDone({required this.result});
  final GoalConfirmResult result;
}

/// An error occurred (decompose or confirm).
final class GoalCreationError extends GoalCreationState {
  GoalCreationError({required this.message});
  final String message;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class GoalCreationNotifier extends Notifier<GoalCreationState> {
  @override
  GoalCreationState build() => GoalCreationIdle();

  GoalsRepository get _repo => ref.read(goalsRepositoryProvider);

  // ── Step 1 → 2: capture title and move to archetype picking ──────

  void startArchetypePick({required String title, String? description}) {
    state = GoalCreationPickingArchetype(title: title, description: description);
  }

  // ── Analyse (calls ai-goal-decompose, or builds an empty own plan) ─

  Future<void> analyse(GoalCreateAnswers answers) async {
    // "Own" plan: no AI call — go straight to an empty review the user
    // fills in by hand (avoids charging energy / a wasted round-trip).
    if (answers.planMode == GoalPlanMode.own) {
      state = GoalCreationReview(
        answers: answers,
        plan: const AiPlan(summary: '', mainCategory: 'mind', steps: []),
      );
      return;
    }

    state = GoalCreationAnalyzing();
    try {
      final plan = await _repo.decomposePlan(answers);
      state = GoalCreationReview(answers: answers, plan: plan);
    } catch (e) {
      state = GoalCreationError(message: e.toString());
    }
  }

  // ── Toggle a step enabled/disabled ───────────────────────────────

  void toggleStep(int index, {required bool enabled}) {
    final s = state;
    if (s is! GoalCreationReview) return;
    final newSteps = List.of(s.plan.steps);
    if (index < 0 || index >= newSteps.length) return;
    newSteps[index] = newSteps[index].copyWith(enabled: enabled);
    state = GoalCreationReview(
      answers: s.answers,
      plan: s.plan.withSteps(newSteps),
    );
  }

  // ── Manual step editing (own / mixed modes) ──────────────────────

  void addStep(AiPlanStep step) {
    final s = state;
    if (s is! GoalCreationReview) return;
    state = GoalCreationReview(
      answers: s.answers,
      plan: s.plan.withSteps([...s.plan.steps, step]),
    );
  }

  void removeStep(int index) {
    final s = state;
    if (s is! GoalCreationReview) return;
    if (index < 0 || index >= s.plan.steps.length) return;
    final newSteps = List.of(s.plan.steps)..removeAt(index);
    state = GoalCreationReview(
      answers: s.answers,
      plan: s.plan.withSteps(newSteps),
    );
  }

  // ── Regenerate plan (same answers, fresh decompose) ──────────────

  Future<void> regenerate() async {
    final s = state;
    if (s is! GoalCreationReview) return;
    await analyse(s.answers);
  }

  // ── Confirm (calls ai-goal-confirm) ──────────────────────────────

  Future<void> confirm() async {
    final s = state;
    if (s is! GoalCreationReview) return;
    state = GoalCreationConfirming(plan: s.plan);
    try {
      final result = await _repo.confirmPlan(
        plan: s.plan,
        answers: s.answers,
      );
      state = GoalCreationDone(result: result);
    } catch (e) {
      state = GoalCreationError(message: e.toString());
    }
  }

  // ── Reset to start a new goal ─────────────────────────────────────

  void reset() => state = GoalCreationIdle();
}

final goalCreationProvider =
    NotifierProvider<GoalCreationNotifier, GoalCreationState>(
  GoalCreationNotifier.new,
);
