import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class AvatarPreview extends StatelessWidget {
  const AvatarPreview({
    super.key,
    required this.hex,
    this.level = 1,
    this.size = 180,
  });

  final String hex;
  final int level;
  final double size;

  Color _color() {
    final s = hex.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final tier = AppColors.levelTierGradient(level);
    final c = _color();
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [...tier, tier.first]),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: AppColors.bgCard,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: size * 0.55, color: c),
          ),
        ],
      ),
    );
  }
}
