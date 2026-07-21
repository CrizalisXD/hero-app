import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_error_view.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../application/challenge_l10n.dart';
import '../../application/challenges_notifier.dart';
import '../../data/supabase_challenges_repository.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_leaderboard.dart';
import '../../domain/models/challenge_metric_type.dart';
import '../../domain/models/challenge_participant.dart';
import '../widgets/challenge_progress_bar.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});
  final String challengeId;

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    try {
      final res =
          await ref.read(challengesRepositoryProvider).join(challengeId);
      ref.invalidate(myChallengesNotifierProvider);
      if (!context.mounted) return;
      if (res.unlocked.isNotEmpty) {
        await AchievementUnlockedSheet.showAll(context, res.unlocked);
        ref.invalidate(achievementsNotifierProvider);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.challengesActionError)),
      );
    }
  }

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.challengesLeaveConfirm),
        content: Text(l.challengesLeaveBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.blockCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.challengesLeave),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(challengesRepositoryProvider).leave(challengeId);
      ref.invalidate(myChallengesNotifierProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.challengesActionError)),
      );
    }
  }

  ChallengeParticipant? _findMine(
    AsyncValue<List<ChallengeParticipant>> mine,
  ) {
    final list = mine.valueOrNull;
    if (list == null) return null;
    for (final p in list) {
      if (p.challengeId == challengeId) return p;
    }
    return null;
  }

  Challenge? _findCatalog(AsyncValue<List<Challenge>> all) {
    final list = all.valueOrNull;
    if (list == null) return null;
    for (final c in list) {
      if (c.id == challengeId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final all = ref.watch(systemChallengesNotifierProvider);
    final mine = ref.watch(myChallengesNotifierProvider);
    final count =
        ref.watch(challengeParticipantsCountProvider(challengeId)).valueOrNull;
    final leaderboard = ref.watch(challengeLeaderboardProvider(challengeId));

    return Scaffold(
      appBar: AppBar(title: Text(l.challengesTitle)),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HeroErrorView(
          onRetry: () => ref.invalidate(systemChallengesNotifierProvider),
        ),
        data: (_) {
          final challenge = _findCatalog(all);
          final p = _findMine(mine);
          // If the user joined a challenge that's no longer in the catalog,
          // we can still render with participant data alone.
          if (challenge == null && p == null) {
            return Center(child: Text(l.challengesEmpty));
          }
          final titleKey = challenge?.titleKey ?? p?.titleKey;
          final bodyKey = challenge?.descriptionKey ?? p?.descriptionKey;
          final titleCustom = challenge?.titleCustom ?? p?.titleCustom;
          final bodyCustom =
              challenge?.descriptionCustom ?? p?.descriptionCustom;
          final title = titleCustom ??
              (titleKey != null ? challengeTitle(context, titleKey) : '');
          final body = bodyCustom ??
              (bodyKey != null ? challengeBody(context, bodyKey) : null);
          final rewardXp = challenge?.rewardXp ?? p!.rewardXp;
          final isJoined = p?.status == ChallengeStatus.joined;
          final completed = p?.status == ChallengeStatus.completed;

          final metric = challenge?.metricType ??
              p?.metricType ??
              ChallengeMetricType.count;
          final target = challenge?.targetValue ?? p?.targetValue;
          final daysLeft =
              challenge?.daysLeft ?? p?.endAt.difference(DateTime.now()).inDays;
          final isOpenEnded =
              (challenge?.isOpenEnded ?? p?.isOpenEnded ?? false) ||
                  (daysLeft != null && daysLeft > 365);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (body != null) ...[
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (count != null)
                    _DetailChip(
                      icon: Icons.people_alt_outlined,
                      label: l.challengesParticipants(count),
                      color: const Color(0xFF4FC3F7),
                    ),
                  if (daysLeft != null && !isOpenEnded)
                    _DetailChip(
                      icon: Icons.schedule,
                      label: l.challengesDaysLeft(daysLeft),
                      color: const Color(0xFFFF6FB5),
                    ),
                  if (target != null && target > 0)
                    _DetailChip(
                      icon: Icons.flag_outlined,
                      label: formatTarget(context, metric, target),
                      color: AppColors.accent,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              if (p != null) ...[
                ChallengeProgressBar(value: p.progress),
                const SizedBox(height: 6),
                Text(
                  formatProgress(
                    context,
                    p.metricType,
                    p.progressValue,
                    p.targetValue,
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                l.challengesRewardCompleted(rewardXp),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              if (completed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l.challengesCompletedBadge,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else if (isJoined)
                HeroButton(
                  label: l.challengesLeave,
                  variant: HeroButtonVariant.secondary,
                  onPressed: () => _leave(context, ref),
                )
              else
                HeroButton(
                  label: l.challengesJoin,
                  onPressed: () => _join(context, ref),
                ),
              _LeaderboardSection(
                data: leaderboard,
                metric: metric,
                target: target,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Leaderboard block on the challenge detail screen. Degrades silently while
/// loading or on error (e.g. before the RPC migration is deployed) so the rest
/// of the screen is never blocked by it.
class _LeaderboardSection extends StatelessWidget {
  const _LeaderboardSection({
    required this.data,
    required this.metric,
    required this.target,
  });

  final AsyncValue<ChallengeLeaderboard> data;
  final ChallengeMetricType metric;
  final num? target;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lb = data.valueOrNull;
    if (lb == null || lb.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Row(
          children: [
            const Icon(
              Icons.leaderboard_outlined,
              size: 18,
              color: AppColors.accent,
            ),
            const SizedBox(width: 6),
            Text(
              l.challengesLeaderboardTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final e in lb.entries)
          _LeaderboardRow(entry: e, metric: metric, target: target),
        if (lb.myRankBelowList && lb.myRank != null) ...[
          const SizedBox(height: 8),
          Text(
            l.challengesMyRank(lb.myRank!, lb.total),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.metric,
    required this.target,
  });

  final LeaderboardEntry entry;
  final ChallengeMetricType metric;
  final num? target;

  Color _rankColor(int rank) => switch (rank) {
        1 => const Color(0xFFD4AF37),
        2 => const Color(0xFFC0C0C0),
        3 => const Color(0xFFCD7F32),
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final rankColor = _rankColor(entry.rank);
    final progressText = (target != null && target! > 0)
        ? formatProgress(context, metric, entry.progress, target!)
        : entry.progress.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isMe
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(12),
        border: entry.isMe
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${entry.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: entry.isMe ? FontWeight.w700 : FontWeight.w500,
                color: entry.isMe ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            progressText,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small meta pill on the detail screen (participants / days-left / goal).
class _DetailChip extends StatelessWidget {
  const _DetailChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
