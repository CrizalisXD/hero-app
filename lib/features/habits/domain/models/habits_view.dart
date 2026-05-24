import 'habit.dart';

class HabitsView {
  const HabitsView({required this.habits, required this.checkedToday});

  final List<Habit> habits;
  final Set<String> checkedToday;

  HabitsView copyWith({List<Habit>? habits, Set<String>? checkedToday}) {
    return HabitsView(
      habits: habits ?? this.habits,
      checkedToday: checkedToday ?? this.checkedToday,
    );
  }
}
