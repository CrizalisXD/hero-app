import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../data/character_stats_repository.dart';

class HeroProgressHeader extends StatelessWidget {
  const HeroProgressHeader({
    super.key,
    required this.displayName,
    required this.character,
  });

  final String displayName;
  final CharacterStats character;

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    final l = context.l10n;
    if (h < 5) return l.homeGreetingNight(displayName);
    if (h < 12) return l.homeGreetingMorning(displayName);
    if (h < 18) return l.homeGreetingDay(displayName);
    return l.homeGreetingEvening(displayName);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lowEnergy = character.energyProgress < 0.25;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(context),
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          l.homeLevel(character.level),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        // XP bar
        AnimatedFillBar(
          progress: character.xpProgress,
          height: 10,
          gradient: AppColors.xpGradient,
          radius: 8,
          duration: const Duration(milliseconds: 700),
        ),
        const SizedBox(height: 4),
        Text(
          l.homeXpProgress(character.xpCurrent, character.xpToNext),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        // Energy bar
        Row(
          children: [
            const Icon(Icons.bolt, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Text(l.homeEnergy, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedFillBar(
                progress: character.energyProgress,
                height: 6,
                gradient: lowEnergy
                    ? AppColors.energyLowGradient
                    : AppColors.energyGradient,
                glowColorOverride:
                    lowEnergy ? AppColors.error : AppColors.warning,
                radius: 6,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.homeEnergyValue(character.energy, character.energyMax),
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
