import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class ChoiceChipGrid extends StatelessWidget {
  const ChoiceChipGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.multiSelect = false,
  });

  final List<({String key, String label})> options;
  final Set<String> selected;
  final void Function(String key) onToggle;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt.key);
        return GestureDetector(
          onTap: () => onToggle(opt.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentDim : AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              opt.label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
