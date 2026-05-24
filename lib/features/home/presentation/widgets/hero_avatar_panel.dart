import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/avatar_repository.dart';

class HeroAvatarPanel extends StatelessWidget {
  const HeroAvatarPanel({
    super.key,
    required this.avatar,
    required this.level,
  });

  final AvatarConfig avatar;
  final int level;

  Color _parseColor(String hex) {
    final s = hex.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(avatar.primaryColor);
    final tier = AppColors.levelTierGradient(level);

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/avatar'),
      child: Center(
        child: SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [...tier, tier.first],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 80, color: color),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$level',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
