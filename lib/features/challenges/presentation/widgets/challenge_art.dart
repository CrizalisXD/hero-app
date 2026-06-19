import 'package:flutter/material.dart';

import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_metric_type.dart';

/// Visual theme used for the challenge card and the detail hero band.
///
/// Sprint C will replace these with commissioned illustrations keyed
/// off a future `art_key` column. For now we derive a sensible icon +
/// gradient tint from the metric type so the new layout already feels
/// distinct per challenge without blocking on art assets.
class ChallengeArt {
  const ChallengeArt({
    required this.icon,
    required this.tint,
    required this.gradient,
  });

  final IconData icon;
  final Color tint;
  final LinearGradient gradient;

  static ChallengeArt forChallenge(Challenge c) =>
      forParts(titleKey: c.titleKey, metric: c.metricType);

  /// Resolve art from the parts available on either a [Challenge] or a
  /// participant row (which has no full Challenge object).
  static ChallengeArt forParts({
    required String? titleKey,
    required ChallengeMetricType metric,
  }) {
    final keyOverride = _byTitleKey(titleKey);
    if (keyOverride != null) return keyOverride;
    return _byMetric(metric);
  }

  static ChallengeArt? _byTitleKey(String? key) {
    switch (key) {
      case 'challengeSummer2026Title':
        return _palette(
          icon: Icons.wb_sunny_outlined,
          base: const Color(0xFFFFB74D),
        );
      case 'challengeSevenDaysActivityTitle':
        return _palette(
          icon: Icons.local_fire_department_outlined,
          base: const Color(0xFFFF7043),
        );
      case 'challengeMonthlyStepsTitle':
        return _palette(
          icon: Icons.directions_walk,
          base: const Color(0xFF66BB6A),
        );
      case 'challengeWeeklyTasksTitle':
        return _palette(
          icon: Icons.check_circle_outline,
          base: const Color(0xFF7F77DD),
        );
      case 'challengeWeeklyActiveDaysTitle':
        return _palette(
          icon: Icons.calendar_today_outlined,
          base: const Color(0xFF42A5F5),
        );
    }
    return null;
  }

  static ChallengeArt _byMetric(ChallengeMetricType type) {
    switch (type) {
      case ChallengeMetricType.distance:
        return _palette(
          icon: Icons.directions_run,
          base: const Color(0xFF66BB6A),
        );
      case ChallengeMetricType.xp:
        return _palette(
          icon: Icons.bolt,
          base: const Color(0xFFFFCA28),
        );
      case ChallengeMetricType.streak:
        return _palette(
          icon: Icons.local_fire_department,
          base: const Color(0xFFFF7043),
        );
      case ChallengeMetricType.habit:
        return _palette(
          icon: Icons.repeat,
          base: const Color(0xFFAB47BC),
        );
      case ChallengeMetricType.category:
        return _palette(
          icon: Icons.category_outlined,
          base: const Color(0xFF26A69A),
        );
      case ChallengeMetricType.activityDay:
        return _palette(
          icon: Icons.calendar_month_outlined,
          base: const Color(0xFF42A5F5),
        );
      case ChallengeMetricType.count:
        return _palette(
          icon: Icons.flag_outlined,
          base: const Color(0xFF7F77DD),
        );
    }
  }

  static ChallengeArt _palette({
    required IconData icon,
    required Color base,
  }) {
    return ChallengeArt(
      icon: icon,
      tint: base,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          base.withValues(alpha: 0.55),
          base.withValues(alpha: 0.15),
        ],
      ),
    );
  }
}
