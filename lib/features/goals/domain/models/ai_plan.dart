import 'ai_plan_step.dart';

/// The full AI-generated plan returned by `ai-goal-decompose`.
class AiPlan {
  const AiPlan({
    required this.summary,
    required this.mainCategory,
    this.secondaryCategories = const [],
    this.estimatedWeeks,
    required this.steps,
    this.warnings = const [],
  });

  final String summary;
  final String mainCategory;
  final List<String> secondaryCategories;
  final int? estimatedWeeks;
  final List<AiPlanStep> steps;
  final List<String> warnings;

  factory AiPlan.fromJson(Map<String, dynamic> j) {
    final rawSecondaries =
        (j['secondary_categories'] as List<dynamic>?)?.cast<String>() ?? [];
    final rawSteps =
        (j['steps'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
    final rawWarnings =
        (j['warnings'] as List<dynamic>?)?.cast<String>() ?? [];
    return AiPlan(
      summary: (j['summary'] as String?) ?? '',
      mainCategory: (j['main_category'] as String?) ?? 'mind',
      secondaryCategories: rawSecondaries,
      estimatedWeeks: (j['estimated_weeks'] as num?)?.toInt(),
      // The AI payload is untrusted — a malformed step without a title
      // would otherwise become a blank task/habit the user can't use.
      steps: rawSteps
          .map(AiPlanStep.fromJson)
          .where((s) => s.title.trim().isNotEmpty)
          .toList(),
      warnings: rawWarnings,
    );
  }

  /// Returns a copy with steps replaced by [newSteps].
  AiPlan withSteps(List<AiPlanStep> newSteps) => AiPlan(
        summary: summary,
        mainCategory: mainCategory,
        secondaryCategories: secondaryCategories,
        estimatedWeeks: estimatedWeeks,
        steps: newSteps,
        warnings: warnings,
      );
}
