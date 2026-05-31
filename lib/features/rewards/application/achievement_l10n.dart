import 'package:flutter/material.dart';

import '../../../core/l10n/l10n.dart';

/// Maps the wire-string `title_key` from `achievements.title_key` to the
/// localised app string. Long switch is intentional — 15 achievements is
/// small enough that codegen overhead isn't worth it. Add a new branch
/// when you add a new achievement to the seed.
String l10nAchievementTitle(BuildContext c, String key) {
  final l = c.l10n;
  return switch (key) {
    'achievementStreak3Title' => l.achievementStreak3Title,
    'achievementStreak5Title' => l.achievementStreak5Title,
    'achievementStreak7Title' => l.achievementStreak7Title,
    'achievementStreak21Title' => l.achievementStreak21Title,
    'achievementLevel5Title' => l.achievementLevel5Title,
    'achievementLevel10Title' => l.achievementLevel10Title,
    'achievementLevel30Title' => l.achievementLevel30Title,
    'achievementFirstGoalTitle' => l.achievementFirstGoalTitle,
    'achievementFirstGoalDoneTitle' => l.achievementFirstGoalDoneTitle,
    'achievementHabit7Title' => l.achievementHabit7Title,
    'achievementHabit21Title' => l.achievementHabit21Title,
    'achievementTask100Title' => l.achievementTask100Title,
    'achievementSocialFirstFriendTitle' => l.achievementSocialFirstFriendTitle,
    'achievementChallengeFirstTitle' => l.achievementChallengeFirstTitle,
    'achievementChallengeCompleteTitle' => l.achievementChallengeCompleteTitle,
    _ => key,
  };
}

String l10nAchievementBody(BuildContext c, String key) {
  final l = c.l10n;
  return switch (key) {
    'achievementStreak3Body' => l.achievementStreak3Body,
    'achievementStreak5Body' => l.achievementStreak5Body,
    'achievementStreak7Body' => l.achievementStreak7Body,
    'achievementStreak21Body' => l.achievementStreak21Body,
    'achievementLevel5Body' => l.achievementLevel5Body,
    'achievementLevel10Body' => l.achievementLevel10Body,
    'achievementLevel30Body' => l.achievementLevel30Body,
    'achievementFirstGoalBody' => l.achievementFirstGoalBody,
    'achievementFirstGoalDoneBody' => l.achievementFirstGoalDoneBody,
    'achievementHabit7Body' => l.achievementHabit7Body,
    'achievementHabit21Body' => l.achievementHabit21Body,
    'achievementTask100Body' => l.achievementTask100Body,
    'achievementSocialFirstFriendBody' => l.achievementSocialFirstFriendBody,
    'achievementChallengeFirstBody' => l.achievementChallengeFirstBody,
    'achievementChallengeCompleteBody' => l.achievementChallengeCompleteBody,
    _ => key,
  };
}

/// Wire `icon_key` → Material icon. Falls back to a star outline for any
/// unknown key. Using `Icons.*` constants (not raw IconData) ensures the
/// icon font is tree-shaken correctly.
IconData achievementIcon(String key) => switch (key) {
      'flame' => Icons.local_fire_department_outlined,
      'star' => Icons.star_outline,
      'flag' => Icons.flag_outlined,
      'calendar' => Icons.calendar_month_outlined,
      'check' => Icons.check_circle_outline,
      'users' => Icons.group_outlined,
      'swords' => Icons.sports_kabaddi_outlined,
      _ => Icons.star_border,
    };
