/// Life areas the user can select during onboarding.
///
/// [wireValue] is the exact string sent to the server.
enum LifeArea {
  health,
  finance,
  mind,
  endurance,
  social,
  creativity,
  strength,
  discipline;

  String get wireValue => switch (this) {
        LifeArea.health => 'health',
        LifeArea.finance => 'finance',
        LifeArea.mind => 'mind',
        LifeArea.endurance => 'endurance',
        LifeArea.social => 'social',
        LifeArea.creativity => 'creativity',
        LifeArea.strength => 'strength',
        LifeArea.discipline => 'discipline',
      };
}
