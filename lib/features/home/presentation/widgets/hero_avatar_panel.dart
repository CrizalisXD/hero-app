import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../data/avatar_repository.dart';

/// Compact avatar tile for the home header.
///
/// Sized to ~104 px so it doesn't dominate the screen, and the level
/// badge is positioned *inside* the circle's visible area (the old
/// `bottom: 4, right: 4` placed it on the bounding-box corner, which
/// is outside the circle — the badge looked detached on the right).
class HeroAvatarPanel extends StatelessWidget {
  const HeroAvatarPanel({
    super.key,
    required this.avatar,
    required this.level,
    this.size = 104,
  });

  final AvatarConfig avatar;
  final int level;
  final double size;

  Color _parseColor(String hex) {
    final s = hex.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(avatar.primaryColor);
    final tier = AppColors.levelTierGradient(level);
    // Position the badge at the 4-5 o'clock position on the circle.
    // The bounding-box offset that lands the badge tangent to the
    // circle is roughly r*(1 - cos45°) ≈ r * 0.29 from each edge.
    final badgeInset = size * 0.08;

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/profile'),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Tier ring
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [...tier, tier.first],
                  ),
                ),
              ),
              // Inner card
              Container(
                margin: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.bgCard,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: size * 0.55,
                  color: color,
                ),
              ),
              // Level badge — pinned inside the circle's bottom-right arc.
              Positioned(
                bottom: badgeInset,
                right: badgeInset,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.bgCard,
                      width: 2,
                    ),
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
