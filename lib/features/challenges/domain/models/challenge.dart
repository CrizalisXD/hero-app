import 'challenge_metric_type.dart';

/// Buckets used to group challenges in the UI and order them on screen.
enum ChallengeKind {
  weekly('weekly'),
  seasonal('seasonal'),
  system('system'),
  user('user'),
  friend('friend');

  const ChallengeKind(this.wire);
  final String wire;

  static ChallengeKind fromWire(String? raw) {
    switch (raw) {
      case 'weekly':
        return ChallengeKind.weekly;
      case 'seasonal':
        return ChallengeKind.seasonal;
      case 'user':
        return ChallengeKind.user;
      case 'friend':
        return ChallengeKind.friend;
      case 'system':
      default:
        return ChallengeKind.system;
    }
  }
}

/// Catalog row from `list_system_challenges` / `list_user_created_challenges`.
///
/// Either [titleKey] (system + seasonal + weekly seeds) or [titleCustom]
/// (user-authored) is set — the UI helper [displayTitle] picks the
/// right one and falls back to a generic label.
class Challenge {
  const Challenge({
    required this.id,
    required this.kind,
    required this.metricType,
    this.titleKey,
    this.descriptionKey,
    this.titleCustom,
    this.descriptionCustom,
    required this.targetValue,
    required this.rewardXp,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final ChallengeKind kind;
  final ChallengeMetricType metricType;
  final String? titleKey;
  final String? descriptionKey;
  final String? titleCustom;
  final String? descriptionCustom;
  final num targetValue;
  final int rewardXp;
  final DateTime startAt;
  final DateTime endAt;

  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
        id: j['id'] as String,
        kind: ChallengeKind.fromWire(j['challenge_type'] as String?),
        metricType:
            ChallengeMetricType.fromWire(j['metric_type'] as String?),
        titleKey: j['title_key'] as String?,
        descriptionKey: j['description_key'] as String?,
        titleCustom: j['title_custom'] as String?,
        descriptionCustom: j['description_custom'] as String?,
        targetValue: (j['target_value'] as num?) ?? 0,
        rewardXp: (j['reward_xp'] as num?)?.toInt() ?? 0,
        startAt: DateTime.parse(j['start_at'] as String),
        endAt: DateTime.parse(j['end_at'] as String),
      );

  int get daysLeft {
    final diff = endAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Seed system challenges run through 2099 — treat as "no deadline".
  bool get isOpenEnded => endAt.year > 2090;
}
