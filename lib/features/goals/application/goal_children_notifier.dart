import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../habits/domain/models/habit.dart';
import '../../tasks/domain/models/task.dart';
import '../domain/models/milestone.dart';

/// Snapshot of every "child" entity linked to a goal — surfaces the
/// AI-generated plan as actually-interactive lists on the goal detail
/// screen.
class GoalChildren {
  const GoalChildren({
    required this.tasks,
    required this.habits,
    required this.milestones,
  });

  final List<Task> tasks;
  final List<Habit> habits;
  final List<Milestone> milestones;
}

final goalChildrenProvider =
    FutureProvider.family<GoalChildren, String>((ref, goalId) async {
  final client = ref.watch(supabaseClientProvider);

  final results = await Future.wait<dynamic>([
    client.from('tasks').select().eq('goal_id', goalId),
    client.from('habits').select().eq('goal_id', goalId),
    client.from('milestones').select().eq('goal_id', goalId),
  ]);

  final tasks = (results[0] as List)
      .map((e) => Task.fromJson(e as Map<String, dynamic>))
      .toList();
  final habits = (results[1] as List)
      .map((e) => Habit.fromJson(e as Map<String, dynamic>))
      .toList();
  final milestones = (results[2] as List)
      .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
      .toList();

  return GoalChildren(
    tasks: tasks,
    habits: habits,
    milestones: milestones,
  );
});
