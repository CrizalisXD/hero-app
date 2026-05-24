import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// A generic chip grid that works with any value type T.
///
/// Using a generic type (enum, String, int …) instead of raw strings
/// keeps wire values out of widgets — they live in enum [wireValue]
/// getters in the domain layer.
class ChoiceChipGrid<T> extends StatelessWidget {
  const ChoiceChipGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.multiSelect = false,
  });

  final List<({T value, String label})> options;
  final Set<T> selected;
  final void Function(T value) onToggle;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt.value);
        return GestureDetector(
          onTap: () => onToggle(opt.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentDim : AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isSelected ? AppColors.accent : AppColors.border,
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
