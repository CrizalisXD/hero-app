import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../application/challenge_l10n.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_metric_type.dart';
import '../../domain/models/challenge_participant.dart';
import 'challenge_art.dart';

/// Universal card used in three places:
///   - "All" tab: ChallengeCard.system(challenge)
///   - "Joined" tab + ActiveChallengesBlock: ChallengeCard.participant(p)
///
/// Redesign: bright gradient art, a progress ring around the art for joined
/// challenges (more glanceable than a bar), and pill chips for the meta
/// (XP, days left). Only real model data — no invented "N participants".
class ChallengeCard extends StatelessWidget {
  const ChallengeCard.system(
    Challenge this.challenge, {
    super.key,
    required this.onTap,
  }) : participant = null;

  const ChallengeCard.participant(
    ChallengeParticipant this.participant, {
    super.key,
    required this.onTap,
  }) : challenge = null;

  final Challenge? challenge;
  final ChallengeParticipant? participant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final titleKey = challenge?.titleKey ?? participant!.titleKey;
    final bodyKey = challenge?.descriptionKey ?? participant?.descriptionKey;
    final rewardXp = challenge?.rewardXp ?? participant!.rewardXp;
    final daysLeft = challenge?.daysLeft ??
        participant!.endAt.difference(DateTime.now()).inDays;
    final isOpen =
        (challenge?.isOpenEnded ?? participant?.isOpenEnded ?? false) ||
            daysLeft > 365;
    final progress = participant?.progress ?? 0.0;
    final completed = participant?.status == ChallengeStatus.completed;
    final metric = participant?.metricType ?? ChallengeMetricType.count;
    final art = ChallengeArt.forParts(titleKey: titleKey, metric: metric);
    final accent = completed ? AppColors.success : art.tint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: HeroCard(
        onTap: onTap,
        glow: true,
        borderColor: accent.withValues(alpha: 0.35),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ArtBadge(
              art: art,
              // Кольцо только для своих челленджей — у системных в списке
              // прогресса ещё нет.
              progress: participant != null && !completed ? progress : null,
              completed: completed,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          challengeTitle(context, titleKey),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (participant != null && !completed) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (participant != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatProgress(
                        context,
                        metric,
                        participant!.progressValue,
                        participant!.targetValue,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else if (bodyKey != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      challengeBody(context, bodyKey),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MetricChip(
                        icon: Icons.bolt,
                        label: '$rewardXp XP',
                        color: const Color(0xFFFFB74D),
                      ),
                      if (completed)
                        _MetricChip(
                          icon: Icons.check_circle,
                          label: l.challengesCompletedBadge,
                          color: AppColors.success,
                        )
                      else if (!isOpen)
                        _MetricChip(
                          icon: Icons.schedule,
                          label: l.challengesDaysLeft(daysLeft),
                          color: const Color(0xFFFF6FB5),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Арт-иконка челленджа. Для своих челленджей вокруг рисуется кольцо
/// прогресса — нагляднее линейной полосы и не занимает отдельную строку.
class _ArtBadge extends StatelessWidget {
  const _ArtBadge({
    required this.art,
    required this.completed,
    this.progress,
  });

  final ChallengeArt art;
  final double? progress;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final ring = progress != null;

    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (ring)
            SizedBox(
              height: size,
              width: size,
              child: CircularProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(art.tint),
              ),
            ),
          // Внутренний градиентный кружок с иконкой. Меньше, если есть кольцо.
          Container(
            height: ring ? 40 : 56,
            width: ring ? 40 : 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  art.tint,
                  art.tint.withValues(alpha: 0.55),
                ],
              ),
              borderRadius: BorderRadius.circular(ring ? 12 : 14),
            ),
            child: Icon(
              completed ? Icons.check : art.icon,
              // Тёмная иконка поверх яркого градиента читается лучше белой.
              color: const Color(0xFF16161E),
              size: ring ? 20 : 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// Пилюля-чип метаданных: иконка + подпись на цветной подложке.
class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
