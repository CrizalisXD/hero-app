import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';

class ColorPickerGrid extends StatelessWidget {
  const ColorPickerGrid({
    super.key,
    required this.selectedHex,
    required this.onSelect,
  });

  final String selectedHex;
  final ValueChanged<String> onSelect;

  static const _palette = <String>[
    '#7F77DD', // accent (default)
    '#B967FF', // bright purple
    '#FFB86C', // legendary orange
    '#E54B4B', // strength red
    '#5B6CFF', // mind blue
    '#23B07A', // endurance green
    '#3DC9C2', // health teal
    '#FFB547', // social amber
    '#F2C94C', // finance gold
    '#BF7CFF', // creativity violet
    '#FF6E6E', // rose
    '#2ECC71', // success green
  ];

  Color _from(String hex) {
    final s = hex.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: _palette.map((hex) {
        final isSelected =
            hex.toUpperCase() == selectedHex.toUpperCase();
        return GestureDetector(
          onTap: () => onSelect(hex),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _from(hex),
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.border,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _from(hex).withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
