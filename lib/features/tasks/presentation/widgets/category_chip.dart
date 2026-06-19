import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../categories/domain/models/category_id.dart';

/// Material icon per category. SVG-style vector icons (no emoji) so the chip
/// reads cleanly at every size — see UI/UX "no-emoji-icons" guideline.
const _categoryIcons = {
  CategoryId.strength: Icons.fitness_center,
  CategoryId.mind: Icons.psychology_alt,
  CategoryId.endurance: Icons.directions_run,
  CategoryId.health: Icons.favorite,
  CategoryId.social: Icons.groups,
  CategoryId.finance: Icons.savings,
  CategoryId.creativity: Icons.palette,
};

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    this.small = false,
    this.fontSize,
  });

  final CategoryId category;
  final bool small;

  /// Override font size. If null, uses [small] to pick 11 or 12.
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    // Single source of truth for category colors (matches categories.json).
    final color = AppColors.categoryColor(category.wire);
    final icon = _categoryIcons[category] ?? Icons.help_outline;
    final label = _categoryLabel(context, category);
    final fs = fontSize ?? (small ? 11.0 : 12.0);
    final padding = fs <= 11
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fs + 2, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fs,
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
