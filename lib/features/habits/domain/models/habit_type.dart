/// Mirrors the Postgres enum `habit_type`.
///
/// • [good]: classic habit — user wants to BUILD it. Check-in awards
///   XP, streak increments on consecutive days.
/// • [bad]: anti-habit — user wants to STOP doing something. Check-in
///   means "I slipped today" → resets streak to 0, stamps last_slip_date,
///   deducts a small discipline penalty, no XP reward. The streak shown
///   in the UI is *computed* as days since the last slip (or since the
///   habit's creation if never slipped) — see Habit.displayStreak.
enum HabitType {
  good('good'),
  bad('bad');

  const HabitType(this.wire);
  final String wire;

  static HabitType fromWire(String? raw) {
    switch (raw) {
      case 'bad':
        return HabitType.bad;
      case 'good':
      default:
        return HabitType.good;
    }
  }
}
