import 'models/create_habit_input.dart';
import 'models/habit.dart';
import 'models/habit_checkin_result.dart';

abstract class HabitsRepository {
  Future<List<Habit>> listActive();
  Future<Set<String>> habitIdsCheckedToday();
  Future<Habit> create(CreateHabitInput input);
  Future<HabitCheckinResult> checkin(String habitId);

  /// Reverses today's [checkin] call. Used for the undo snackbar.
  Future<void> uncheckin(String habitId);

  Future<void> archive(String habitId);
  Future<void> delete(String habitId);
}
