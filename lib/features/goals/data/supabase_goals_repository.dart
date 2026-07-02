import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/goals_repository.dart';
import '../domain/models/ai_plan.dart';
import '../domain/models/goal.dart';
import '../domain/models/goal_confirm_result.dart';
import '../domain/models/goal_create_answers.dart';
import '../domain/models/goal_progress.dart';

class SupabaseGoalsRepository implements GoalsRepository {
  SupabaseGoalsRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not_authenticated');
    return id;
  }

  // ── Edge Functions ────────────────────────────────────────────────

  @override
  Future<AiPlan> decomposePlan(GoalCreateAnswers answers) async {
    final res = await _client.functions.invoke(
      'ai-goal-decompose',
      body: answers.toDecomposePayload(locale: 'ru'),
    );

    if (res.status != 200) {
      final msg = _extractError(res.data) ?? 'decompose_failed';
      throw Exception(msg);
    }

    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('decompose_bad_response');
    if (data['ok'] != true) {
      throw Exception(data['error'] as String? ?? 'decompose_error');
    }

    return AiPlan.fromJson(data);
  }

  @override
  Future<GoalConfirmResult> confirmPlan({
    required AiPlan plan,
    required GoalCreateAnswers answers,
  }) async {
    // target_date is derived from the chosen period (now + planPeriodDays).
    // Kept for backwards compat: ai-chat's system prompt still reads it.
    final targetDate = DateTime.now().add(
      Duration(days: answers.planPeriodDays),
    );
    final payload = <String, dynamic>{
      'goal_title': answers.title,
      if (answers.description != null && answers.description!.isNotEmpty)
        'goal_description': answers.description,
      'main_category': plan.mainCategory,
      'secondary_categories': plan.secondaryCategories,
      'archetype': answers.archetype.wire,
      'plan_mode': answers.planMode.wire,
      'plan_period_days': answers.planPeriodDays,
      'target_date': targetDate.toIso8601String().split('T').first,
      'steps': plan.steps
          .where((s) => s.enabled)
          .map((s) => s.toJson())
          .toList(),
    };

    final res = await _client.functions.invoke(
      'ai-goal-confirm',
      body: payload,
    );

    if (res.status != 200) {
      final msg = _extractError(res.data) ?? 'confirm_failed';
      throw Exception(msg);
    }

    final data = res.data;
    if (data is! Map<String, dynamic>) throw Exception('confirm_bad_response');
    if (data['ok'] != true) {
      throw Exception(data['error'] as String? ?? 'confirm_error');
    }

    return GoalConfirmResult.fromJson(data);
  }

  // ── DB reads ─────────────────────────────────────────────────────

  @override
  Future<List<Goal>> fetchGoals() async {
    final uid = _uid;
    final rows = await _client
        .from('goals')
        .select()
        .eq('user_id', uid)
        .eq('is_deleted', false)
        .order('created_at', ascending: false);

    return (rows as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Goal.fromJson)
        .toList();
  }

  @override
  Future<List<GoalProgress>> fetchProgress() async {
    final rows = await _client.rpc<List<dynamic>>('goal_progress_me');
    return rows
        .cast<Map<String, dynamic>>()
        .map(GoalProgress.fromJson)
        .toList();
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _client
        .from('goals')
        .update({'is_deleted': true})
        .eq('id', goalId)
        .eq('user_id', _uid);
  }

  @override
  Future<void> updateStatus(String goalId, GoalStatus status) async {
    await _client
        .from('goals')
        .update({'status': _statusWire(status)})
        .eq('id', goalId)
        .eq('user_id', _uid);
  }

  @override
  Future<void> extendGoal(String goalId, DateTime targetDate) async {
    await _client
        .from('goals')
        .update({
          'target_date': targetDate.toIso8601String().split('T').first,
          'status': _statusWire(GoalStatus.extended),
        })
        .eq('id', goalId)
        .eq('user_id', _uid);
  }

  String _statusWire(GoalStatus s) => switch (s) {
        GoalStatus.active => 'active',
        GoalStatus.completed => 'completed',
        GoalStatus.paused => 'paused',
        GoalStatus.abandoned => 'abandoned',
        GoalStatus.extended => 'extended',
      };

  @override
  Future<GoalProgress?> progressOf(String goalId) async {
    final all = await fetchProgress();
    try {
      return all.firstWhere((p) => p.goalId == goalId);
    } catch (_) {
      return null;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String? _extractError(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['error'] as String?;
    }
    return null;
  }
}

final goalsRepositoryProvider = Provider<GoalsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseGoalsRepository(client);
});
