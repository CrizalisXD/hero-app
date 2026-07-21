import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/achievement_l10n.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/user_achievement.dart';

/// Detail sheet shown when a reward tile is tapped. Read-only: big icon,
/// title, rarity, description, reward and unlock status. Progress toward a
/// locked achievement isn't in the catalog view, so locked entries just show
/// the "how to earn" description + a locked badge.
class AchievementDetailSheet extends StatelessWidget {
  const AchievementDetailSheet({
    super.key,
    required this.achievement,
    required this.unlocked,
    this.userAchievement,
  });

  final Achievement achievement;
  final bool unlocked;
  final UserAchievement? userAchievement;

  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
    required bool unlocked,
    UserAchievement? userAchievement,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AchievementDetailSheet(
        achievement: achievement,
        unlocked: unlocked,
        userAchievement: userAchievement,
      ),
    );
  }

  Color _rarityColor(AchievementRarity r) => switch (r) {
        AchievementRarity.legendary => AppColors.rarityLegendary,
        AchievementRarity.epic => AppColors.rarityEpic,
        AchievementRarity.rare => AppColors.rarityRare,
        AchievementRarity.common => AppColors.rarityCommon,
      };

  String _rarityLabel(AppLocalizations l, AchievementRarity r) => switch (r) {
        AchievementRarity.legendary => l.rarityLegendary,
        AchievementRarity.epic => l.rarityEpic,
        AchievementRarity.rare => l.rarityRare,
        AchievementRarity.common => l.rarityCommon,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = _rarityColor(achievement.rarity);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grab handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: 20),
          // Icon medallion
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: color.withValues(alpha: unlocked ? 0.2 : 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: unlocked ? 0.8 : 0.35),
                width: 2,
              ),
            ),
            child: Icon(
              unlocked
                  ? achievementIcon(achievement.iconKey)
                  : Icons.lock_outline,
              size: 40,
              color: unlocked ? color : color.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10nAchievementTitle(context, achievement.titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          // Rarity chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Text(
              _rarityLabel(l, achievement.rarity),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10nAchievementBody(context, achievement.descriptionKey),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Reward row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${l.rewardsRewardLabel}:  ',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const Icon(Icons.bolt, size: 16, color: AppColors.accent),
              Text(
                '+${achievement.rewardXp} XP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              if (achievement.rewardCoins > 0) ...[
                const SizedBox(width: 12),
                const Icon(
                  Icons.monetization_on_outlined,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
                Text(
                  '+${achievement.rewardCoins}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _StatusBadge(unlocked: unlocked, userAchievement: userAchievement),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.unlocked, this.userAchievement});

  final bool unlocked;
  final UserAchievement? userAchievement;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = unlocked ? AppColors.success : AppColors.textMuted;
    final ua = userAchievement;
    final date = (unlocked && ua != null)
        ? '  ·  ${DateFormat.yMMMd().format(ua.unlockedAt.toLocal())}'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.check_circle : Icons.lock_clock,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '${unlocked ? l.rewardsUnlockedStatus : l.rewardsLockedStatus}$date',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
