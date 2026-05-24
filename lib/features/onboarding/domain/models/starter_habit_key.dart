/// Starter habits the user can pick during onboarding.
///
/// [wireValue] is the exact string sent to the server.
enum StarterHabitKey {
  drinkWater,
  read10Pages,
  walk10Min;

  String get wireValue => switch (this) {
        StarterHabitKey.drinkWater => 'drink_water',
        StarterHabitKey.read10Pages => 'read_10_pages',
        StarterHabitKey.walk10Min => 'walk_10_min',
      };
}
