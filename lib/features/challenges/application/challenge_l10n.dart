import 'package:flutter/widgets.dart';

import '../../../core/l10n/l10n.dart';
import '../domain/models/challenge_metric_type.dart';

/// Seed system challenges only — extend this switch when adding more.
String challengeTitle(BuildContext c, String key) {
  final l = c.l10n;
  return switch (key) {
    'challengeSevenDaysActivityTitle' => l.challengeSevenDaysActivityTitle,
    'challengeMonthlyStepsTitle' => l.challengeMonthlyStepsTitle,
    'challengeSummer2026Title' => l.challengeSummer2026Title,
    _ => key,
  };
}

String challengeBody(BuildContext c, String? key) {
  if (key == null) return '';
  final l = c.l10n;
  return switch (key) {
    'challengeSevenDaysActivityBody' => l.challengeSevenDaysActivityBody,
    'challengeMonthlyStepsBody' => l.challengeMonthlyStepsBody,
    'challengeSummer2026Body' => l.challengeSummer2026Body,
    _ => key,
  };
}

/// Formats progress for display: "30/30000 m" / "5/7" / "120/200 XP".
/// Distance is server-side in metres; UI keeps the raw int for honesty
/// (km conversion can come later as a UX polish).
String formatProgress(
  BuildContext c,
  ChallengeMetricType type,
  num cur,
  num target,
) {
  final l = c.l10n;
  String fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  final unit = switch (type) {
    ChallengeMetricType.distance => ' m',
    ChallengeMetricType.xp => ' XP',
    _ => '',
  };
  return l.challengesProgressLabel(fmt(cur) + unit, fmt(target) + unit);
}

/// Target-only label for the detail screen: "Goal: 30000 m" / "Цель: 7".
String formatTarget(BuildContext c, ChallengeMetricType type, num target) {
  final l = c.l10n;
  String fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
  final unit = switch (type) {
    ChallengeMetricType.distance => ' m',
    ChallengeMetricType.xp => ' XP',
    _ => '',
  };
  return l.challengesGoal(fmt(target) + unit);
}
