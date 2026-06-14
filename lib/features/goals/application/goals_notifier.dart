import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_goals_repository.dart';
import '../domain/goals_repository.dart';
import '../domain/models/goal.dart';
import '../domain/models/goal_progress.dart';

// ── Combined view ─────────────────────────────────────────────────────────────

class GoalsView {
  const GoalsView({
    required this.goals,
    required this.progress,
  });

  final List<Goal> goals;
  final Map<String, GoalProgress> progress; // keyed by goalId

  GoalProgress? progressFor(String goalId) => progress[goalId];
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class GoalsNotifier extends AsyncNotifier<GoalsView> {
  @override
  Future<GoalsView> build() => _load();

  GoalsRepository get _repo => ref.read(goalsRepositoryProvider);

  Future<GoalsView> _load() async {
    final goalsFuture = _repo.fetchGoals();
    final progressFuture = _repo.fetchProgress();
    final goals = await goalsFuture;
    final progressList = await progressFuture;
    final progressMap = {for (final p in progressList) p.goalId: p};
    return GoalsView(goals: goals, progress: progressMap);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Called after a goal is confirmed so the list refreshes immediately.
  Future<void> onGoalCreated() => reload();

  /// Optimistically removes the goal from the list, then calls the
  /// server soft-delete RPC. On failure the row is restored.
  Future<void> deleteGoal(String goalId) async {
    final previous = state.value;
    if (previous == null) return;
    final next = GoalsView(
      goals: previous.goals.where((g) => g.id != goalId).toList(),
      progress: previous.progress,
    );
    state = AsyncData(next);
    try {
      await ref.read(goalsRepositoryProvider).deleteGoal(goalId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

final goalsNotifierProvider =
    AsyncNotifierProvider<GoalsNotifier, GoalsView>(GoalsNotifier.new);
