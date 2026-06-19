import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../application/challenge_l10n.dart';
import '../../application/challenges_notifier.dart';
import '../../data/supabase_challenges_repository.dart';
import '../../domain/models/challenge.dart';
import '../../domain/models/challenge_metric_type.dart';
import '../../domain/models/challenge_participant.dart';
import '../widgets/challenge_progress_bar.dart';

class ChallengeDetailScreen extends ConsumerWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});
  final String challengeId;

  Future<void> _join(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    try {
      final res = await ref
          .read(challengesRepositoryProvider)
          .join(challengeId);
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

    return Scaffold(
      appBar: AppBar(title: Text(l.challengesTitle)),
      body: all.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (_) {
          final challenge = _findCatalog(all);
          final p = _findMine(mine);
          // If the user joined a challenge that's no longer in the catalog,
          // we can still render with participant data alone.
          if (challenge == null && p == null) {
            return Center(child: Text(l.challengesEmpty));
          }
          final titleKey = challenge?.titleKey ?? p!.titleKey;
          final bodyKey = challenge?.descriptionKey ?? p?.descriptionKey;
          final rewardXp = challenge?.rewardXp ?? p!.rewardXp;
          final isJoined = p?.status == ChallengeStatus.joined;
          final completed = p?.status == ChallengeStatus.completed;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                challengeTitle(context, titleKey),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bodyKey != null) ...[
                const SizedBox(height: 8),
                Text(
                  challengeBody(context, bodyKey),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
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
            ],
          );
        },
      ),
    );
  }
}
