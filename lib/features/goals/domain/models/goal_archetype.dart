/// The kind of goal the user is pursuing. Drives which follow-up questions
/// the create flow asks and how the AI structures the plan.
///
/// Backwards compatibility: goals created before Phase 19 (and any unknown
/// wire value) resolve to [GoalArchetype.custom].
enum GoalArchetype {
  skillLearning('skill_learning'),
  habitBuilding('habit_building'),
  fitnessHealth('fitness_health'),
  projectCreation('project_creation'),
  moneyPurchase('money_purchase'),
  eventPreparation('event_preparation'),
  relationshipGoal('relationship_goal'),
  lifeChange('life_change'),
  custom('custom');

  const GoalArchetype(this.wire);

  final String wire;

  static GoalArchetype fromWire(String? raw) {
    return GoalArchetype.values.firstWhere(
      (e) => e.wire == raw,
      orElse: () => GoalArchetype.custom,
    );
  }
}
