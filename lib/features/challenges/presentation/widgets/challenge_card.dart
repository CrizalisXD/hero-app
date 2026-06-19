import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../../core/widgets/xp_badge.dart';
import '../../application/challenge_l10n.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_metric_type.dart';
import '../../domain/models/challenge_participant.dart';
import 'challenge_art.dart';
import 'challenge_progress_bar.dart';

/// Universal card used in three places:
///   - "All" tab: ChallengeCard.system(challenge)
///   - "Joined" tab + ActiveChallengesBlock: ChallengeCard.participant(p)
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: HeroCard(
        onTap: onTap,
        borderColor: completed ? AppColors.success : art.tint.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Per-challenge art icon — distinct color/icon per metric or seed.
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: art.gradient,
                borderRadius: BorderRadius.circular(AppRadius.m),
                border: Border.all(color: art.tint.withValues(alpha: 0.4)),
              ),
              child: Icon(art.icon, color: art.tint, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          challengeTitle(context, titleKey),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      XpBadge(xp: rewardXp),
                    ],
                  ),
                  if (bodyKey != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      challengeBody(context, bodyKey),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (participant != null) ...[
                    const SizedBox(height: 10),
                    ChallengeProgressBar(value: progress),
                    const SizedBox(height: 4),
                    Text(
                      formatProgress(
                        context,
                        metric,
                        participant!.progressValue,
                        participant!.targetValue,
                      ),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  if (completed || !isOpen) ...[
                    const SizedBox(height: 6),
                    if (completed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          l.challengesCompletedBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        l.challengesDaysLeft(daysLeft),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
