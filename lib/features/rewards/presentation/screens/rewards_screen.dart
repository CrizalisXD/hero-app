import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_error_view.dart';
import '../../application/achievement_l10n.dart';
import '../../application/achievements_notifier.dart';
import '../../domain/models/achievement.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Color _rarityColor(AchievementRarity r) => switch (r) {
        AchievementRarity.legendary => AppColors.rarityLegendary,
        AchievementRarity.epic => AppColors.rarityEpic,
        AchievementRarity.rare => AppColors.rarityRare,
        AchievementRarity.common => AppColors.rarityCommon,
      };

  Widget _tile(BuildContext c, Achievement a, bool unlocked) {
    final color = _rarityColor(a.rarity);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: HeroCard(
        padding: const EdgeInsets.all(12),
        borderColor: color.withValues(alpha: unlocked ? 0.55 : 0.22),
        child: Row(
          children: [
            // Rarity accent stripe — gives the list color rhythm.
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: unlocked ? 0.9 : 0.5),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: unlocked ? 0.2 : 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withValues(alpha: unlocked ? 0.7 : 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                unlocked ? achievementIcon(a.iconKey) : Icons.lock_outline,
                color: unlocked ? color : color.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nAchievementTitle(c, a.titleKey),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10nAchievementBody(c, a.descriptionKey),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Rarity-tinted reward pill.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: unlocked ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 13, color: color),
                  const SizedBox(width: 1),
                  Text(
                    '+${a.rewardXp}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final state = ref.watch(achievementsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.rewardsTitle),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: l.rewardsTabAll),
            Tab(text: l.rewardsTabUnlocked),
            Tab(text: l.rewardsTabLocked),
          ],
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HeroErrorView(onRetry: () => ref.invalidate(achievementsNotifierProvider)),
        data: (view) {
          List<Achievement> filter(int tab) {
            final list = view.all;
            return switch (tab) {
              1 => list.where((a) => view.isUnlocked(a.id)).toList(),
              2 => list.where((a) => !view.isUnlocked(a.id)).toList(),
              _ => list,
            };
          }

          Widget tabView(int i) {
            final items = filter(i);
            if (items.isEmpty) return Center(child: Text(l.rewardsEmpty));
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(achievementsNotifierProvider.notifier).refresh(),
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (c, idx) =>
                    _tile(c, items[idx], view.isUnlocked(items[idx].id)),
              ),
            );
          }

          return TabBarView(
            controller: _tab,
            children: [tabView(0), tabView(1), tabView(2)],
          );
        },
      ),
    );
  }
}
