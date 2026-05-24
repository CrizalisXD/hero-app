import '../../goals/domain/models/goal.dart';
import '../../goals/domain/models/goal_progress.dart';
import '../../habits/domain/models/habit.dart';
import '../../tasks/domain/models/task.dart';
import '../data/avatar_repository.dart';
import '../data/character_stats_repository.dart';

class HomeData {
  const HomeData({
    required this.displayName,
    required this.character,
    required this.avatar,
    required this.todayTasks,
    required this.activeHabits,
    required this.habitsCheckedToday,
    required this.activeGoal,
    required this.activeGoalProgress,
  });

  final String displayName;
  final CharacterStats character;
  final AvatarConfig avatar;
  final List<Task> todayTasks;
  final List<Habit> activeHabits;
  final Set<String> habitsCheckedToday;
  final Goal? activeGoal;
  final GoalProgress? activeGoalProgress;
}
