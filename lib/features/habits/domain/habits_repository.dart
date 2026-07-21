import 'models/create_habit_input.dart';
import 'models/habit.dart';
import 'models/habit_checkin_result.dart';

abstract class HabitsRepository {
  Future<List<Habit>> listActive();
  Future<Set<String>> habitIdsCheckedToday();
  Future<Habit> create(CreateHabitInput input);

  /// Narrow inline edit: title + optional description only. Category, XP and
  /// difficulty stay as the classifier set them — same scope as EditTaskSheet,
  /// so no XP recompute is needed.
  Future<Habit> update(
    String habitId, {
    required String title,
    String? description,
  });

  Future<HabitCheckinResult> checkin(String habitId);

  /// Reverses today's [checkin] call. Used for the undo snackbar.
  Future<void> uncheckin(String habitId);

  /// Mark today as a conscious "skip" for this habit — no XP, streak
  /// untouched. Used so a planned-off day (travel, sick) doesn't break
  /// the chain.
  Future<void> skipToday(String habitId);

  Future<void> archive(String habitId);
  Future<void> delete(String habitId);
}
