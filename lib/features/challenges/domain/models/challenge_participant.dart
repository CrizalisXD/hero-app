import 'challenge_metric_type.dart';

/// Row from `list_my_challenges` RPC — flat join of
/// challenge_participants + challenges.
class ChallengeParticipant {
  const ChallengeParticipant({
    required this.participantId,
    required this.challengeId,
    required this.metricType,
    this.titleKey,
    this.descriptionKey,
    this.titleCustom,
    this.descriptionCustom,
    required this.targetValue,
    required this.progressValue,
    required this.status,
    required this.rewardXp,
    required this.endAt,
    required this.joinedAt,
    this.completedAt,
  });

  final String participantId;
  final String challengeId;
  final ChallengeMetricType metricType;

  /// Системные челленджи несут ключ локализации ([titleKey]); пользовательские
  /// — произвольный текст ([titleCustom]). Всегда задан ровно один. Раньше
  /// titleKey был non-null и падал на пользовательских — отсюда ошибка «Мои».
  final String? titleKey;
  final String? descriptionKey;
  final String? titleCustom;
  final String? descriptionCustom;
  final num targetValue;
  final num progressValue;
  final ChallengeStatus status;
  final int rewardXp;
  final DateTime endAt;
  final DateTime joinedAt;
  final DateTime? completedAt;

  /// 0..1 ratio for progress bars.
  double get progress {
    if (targetValue == 0) return 0;
    return (progressValue / targetValue).clamp(0, 1).toDouble();
  }

  bool get isOpenEnded => endAt.year > 2090;

  factory ChallengeParticipant.fromJson(Map<String, dynamic> j) =>
      ChallengeParticipant(
        participantId: j['participant_id'] as String,
        challengeId: j['challenge_id'] as String,
        metricType:
            ChallengeMetricType.fromWire(j['metric_type'] as String?),
        titleKey: j['title_key'] as String?,
        descriptionKey: j['description_key'] as String?,
        titleCustom: j['title_custom'] as String?,
        descriptionCustom: j['description_custom'] as String?,
        targetValue: (j['target_value'] as num?) ?? 0,
        progressValue: (j['progress_value'] as num?) ?? 0,
        status: ChallengeStatus.fromWire(j['status'] as String?),
        rewardXp: (j['reward_xp'] as num?)?.toInt() ?? 0,
        endAt: DateTime.parse(j['end_at'] as String),
        joinedAt: DateTime.parse(j['joined_at'] as String),
        completedAt: j['completed_at'] == null
            ? null
            : DateTime.parse(j['completed_at'] as String),
      );
}
