import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../categories/domain/models/category_id.dart';

const _categoryColors = {
  CategoryId.strength: Color(0xFFE54B4B),
  CategoryId.mind: Color(0xFF7F77DD),
  CategoryId.endurance: Color(0xFFE5A54B),
  CategoryId.health: Color(0xFF4BE57F),
  CategoryId.social: Color(0xFF4BB5E5),
  CategoryId.finance: Color(0xFFE5D14B),
  CategoryId.creativity: Color(0xFFE54BB5),
};

const _categoryIcons = {
  CategoryId.strength: '💪',
  CategoryId.mind: '🧠',
  CategoryId.endurance: '🏃',
  CategoryId.health: '❤️',
  CategoryId.social: '🤝',
  CategoryId.finance: '💰',
  CategoryId.creativity: '🎨',
};

class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category, this.small = false});

  final CategoryId category;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category] ?? const Color(0xFF7F77DD);
    final icon = _categoryIcons[category] ?? '❓';
    final label = _categoryLabel(context, category);
    final fontSize = small ? 11.0 : 12.0;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: TextStyle(fontSize: fontSize)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _categoryLabel(BuildContext context, CategoryId id) {
    final l = context.l10n;
    return switch (id) {
      CategoryId.strength => l.categoryStrength,
      CategoryId.mind => l.categoryMind,
      CategoryId.endurance => l.categoryEndurance,
      CategoryId.health => l.categoryHealth,
      CategoryId.social => l.categorySocial,
      CategoryId.finance => l.categoryFinance,
      CategoryId.creativity => l.categoryCreativity,
    };
  }
}
