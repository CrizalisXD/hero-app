/// What kind of value a challenge is tracking. The wire form lives in
/// `challenges.metric_type` and is read by server triggers when deciding
/// whether an event (task_completed, habit_logged, …) bumps progress.
enum ChallengeMetricType {
  streak,
  count,
  distance,
  xp,
  habit,
  category,
  activityDay;

  String get wire => switch (this) {
        ChallengeMetricType.streak => 'streak',
        ChallengeMetricType.count => 'count',
        ChallengeMetricType.distance => 'distance',
        ChallengeMetricType.xp => 'xp',
        ChallengeMetricType.habit => 'habit',
        ChallengeMetricType.category => 'category',
        ChallengeMetricType.activityDay => 'activity_day',
      };

  static ChallengeMetricType fromWire(String? raw) => switch (raw) {
        'streak' => ChallengeMetricType.streak,
        'count' => ChallengeMetricType.count,
        'distance' => ChallengeMetricType.distance,
        'xp' => ChallengeMetricType.xp,
        'habit' => ChallengeMetricType.habit,
        'category' => ChallengeMetricType.category,
        'activity_day' => ChallengeMetricType.activityDay,
        _ => ChallengeMetricType.count,
      };
}

enum ChallengeStatus {
  joined,
  completed,
  failed,
  left;

  String get wire => name;

  static ChallengeStatus fromWire(String? raw) => switch (raw) {
        'completed' => ChallengeStatus.completed,
        'failed' => ChallengeStatus.failed,
        'left' => ChallengeStatus.left,
        _ => ChallengeStatus.joined,
      };
}
