import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greeting(context),
          style: const TextStyle(fontSize: 13, color: Color(0xB3FFFFFF)),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(height: 10, color: AppColors.bgElevated),
              FractionallySizedBox(
                widthFactor: character.xpProgress,
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: AppColors.xpGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l.homeXpProgress(character.xpCurrent, character.xpToNext),
          style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF)),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(height: 6, color: AppColors.bgElevated),
                    FractionallySizedBox(
                      widthFactor: character.energyProgress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: character.energyProgress < 0.25
                              ? AppColors.energyLowGradient
                              : AppColors.energyGradient,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.homeEnergyValue(character.energy, character.energyMax),
              style: const TextStyle(fontSize: 11, color: Color(0xB3FFFFFF)),
            ),
          ],
        ),
      ],
    );
  }
}
