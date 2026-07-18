import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';

/// Строка оценки 1..5 одним рядом иконок. Используется и для сложности
/// (сообществом), и для «стоило того» (сделавшими) — разница лишь в цвете
/// и иконке.
class DreamRatingRow extends StatelessWidget {
  const DreamRatingRow({
    super.key,
    required this.question,
    required this.value,
    required this.color,
    required this.onRate,
    this.icon = Icons.circle,
  });

  final String question;

  /// Текущая оценка (1..5), null — ещё не оценивал.
  final int? value;
  final Color color;
  final IconData icon;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Semantics(
                  button: true,
                  label: '$i',
                  selected: value != null && i <= value!,
                  child: InkResponse(
                    radius: 22,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onRate(i);
                    },
                    child: Icon(
                      icon,
                      size: 26,
                      color: (value != null && i <= value!)
                          ? color
                          : AppColors.textSecondary.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
