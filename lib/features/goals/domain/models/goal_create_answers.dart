import 'goal_archetype.dart';
import 'goal_plan_mode.dart';

/// User answers from the goal create flow (title screen + archetype screen).
/// Serialises to the payload expected by `ai-goal-decompose` / `ai-goal-confirm`.
///
/// Archetype-specific fields are nullable and only sent when relevant for the
/// chosen [archetype] (see the table in PHASE_19_TZ).
class GoalCreateAnswers {
  const GoalCreateAnswers({
    required this.title,
    this.description,
    required this.planPeriodDays,
    required this.minutesPerDay,
    required this.archetype,
    this.planMode = GoalPlanMode.ai,
    this.currentLevel,
    this.hasMaterials,
    this.targetAmount,
    this.targetCurrency,
    this.eventDate,
  });

  final String title;
  final String? description;

  /// Calendar days the user wants the plan to span (7 / 30 / 90 / custom).
  final int planPeriodDays;

  /// Minutes the user is willing to spend per day.
  final int minutesPerDay;

  final GoalArchetype archetype;
  final GoalPlanMode planMode;

  // ── Archetype-specific (nullable) ──────────────────────────────────
  /// 'beginner' | 'intermediate' | 'advanced' — skill_learning, fitness_health
  final String? currentLevel;

  /// skill_learning, project_creation
  final bool? hasMaterials;

  /// money_purchase — target sum
  final double? targetAmount;

  /// money_purchase — ISO currency code
  final String? targetCurrency;

  /// event_preparation — date of the event
  final DateTime? eventDate;

  GoalCreateAnswers copyWith({
    String? title,
    String? description,
    int? planPeriodDays,
    int? minutesPerDay,
    GoalArchetype? archetype,
    GoalPlanMode? planMode,
    String? currentLevel,
    bool? hasMaterials,
    double? targetAmount,
    String? targetCurrency,
    DateTime? eventDate,
  }) {
    return GoalCreateAnswers(
      title: title ?? this.title,
      description: description ?? this.description,
      planPeriodDays: planPeriodDays ?? this.planPeriodDays,
      minutesPerDay: minutesPerDay ?? this.minutesPerDay,
      archetype: archetype ?? this.archetype,
      planMode: planMode ?? this.planMode,
      currentLevel: currentLevel ?? this.currentLevel,
      hasMaterials: hasMaterials ?? this.hasMaterials,
      targetAmount: targetAmount ?? this.targetAmount,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      eventDate: eventDate ?? this.eventDate,
    );
  }

  Map<String, dynamic> toDecomposePayload({String locale = 'ru'}) => {
        'goal_title': title,
        if (description != null && description!.isNotEmpty)
          'goal_description': description,
        'locale': locale,
        'archetype': archetype.wire,
        'plan_mode': planMode.wire,
        'answers': {
          'deadline_days': planPeriodDays,
          'minutes_per_day': minutesPerDay,
          if (currentLevel != null) 'current_level': currentLevel,
          if (hasMaterials != null) 'has_materials': hasMaterials,
          if (targetAmount != null) 'target_amount': targetAmount,
          if (targetCurrency != null) 'target_currency': targetCurrency,
          if (eventDate != null)
            'event_date': eventDate!.toIso8601String().split('T').first,
        },
      };
}
