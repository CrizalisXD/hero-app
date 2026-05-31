import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../application/achievement_l10n.dart';
import '../../domain/models/achievement.dart';
import '../../domain/models/unlocked_achievement.dart';

/// Modal bottom sheet shown when one or more achievements unlock.
/// If several unlock at once, sheets appear one after another.
class AchievementUnlockedSheet {
  AchievementUnlockedSheet._();

  static Future<void> showAll(
    BuildContext context,
    List<UnlockedAchievement> list,
  ) async {
    for (final a in list) {
      if (!context.mounted) break;
      await _showOne(context, a);
    }
  }

  static Future<void> _showOne(
    BuildContext context,
    UnlockedAchievement a,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _Body(a: a),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body({required this.a});
  final UnlockedAchievement a;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _rarityColor(AchievementRarity r) => switch (r) {
        AchievementRarity.legendary => AppColors.rarityLegendary,
        AchievementRarity.epic => AppColors.rarityEpic,
        AchievementRarity.rare => AppColors.rarityRare,
        AchievementRarity.common => AppColors.rarityCommon,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = _rarityColor(widget.a.rarity);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
            child: Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [color.withValues(alpha: 0.4), AppColors.bgCard],
                ),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                achievementIcon(widget.a.iconKey),
                size: 44,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l.achievementUnlockedTitle,
            style: const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF)),
          ),
          const SizedBox(height: 6),
          Text(
            l10nAchievementTitle(context, widget.a.titleKey),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l10nAchievementBody(context, widget.a.descriptionKey),
            style: const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF)),
            textAlign: TextAlign.center,
          ),
          if (widget.a.rewardXp > 0) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                l.achievementRewardXp(widget.a.rewardXp),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.achievementClose),
          ),
        ],
      ),
    );
  }
}
