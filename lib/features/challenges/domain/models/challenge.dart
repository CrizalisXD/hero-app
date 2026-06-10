import 'challenge_metric_type.dart';

/// Catalog row from `list_system_challenges` RPC.
class Challenge {
  const Challenge({
    required this.id,
    required this.metricType,
    required this.titleKey,
    this.descriptionKey,
    required this.targetValue,
    required this.rewardXp,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final ChallengeMetricType metricType;
  final String titleKey;
  final String? descriptionKey;
  final num targetValue;
  final int rewardXp;
  final DateTime startAt;
  final DateTime endAt;

  factory Challenge.fromJson(Map<String, dynamic> j) => Challenge(
        id: j['id'] as String,
        metricType:
            ChallengeMetricType.fromWire(j['metric_type'] as String?),
        titleKey: j['title_key'] as String,
        descriptionKey: j['description_key'] as String?,
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
