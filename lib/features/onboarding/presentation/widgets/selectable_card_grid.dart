import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';

/// Опция карточки-грида: ключ, подпись, иконка, опциональные описание
/// и акцентный цвет (для категорий — их фирменный цвет).
class CardGridOption {
  const CardGridOption({
    required this.key,
    required this.label,
    required this.icon,
    this.description,
    this.tint,
  });

  final String key;
  final String label;
  final IconData icon;
  final String? description;
  final Color? tint;
}

/// Грид карточек в стиле мокапа: 2 колонки, круглая иконка, выбранная —
/// фиолетовая заливка с glow, невыбранные пригашены (но читаемы).
class SelectableCardGrid extends StatelessWidget {
  const SelectableCardGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.multiSelect = false,
    this.maxSelect,
    this.columns = 2,
    this.aspectRatio = 1.15,
  });

  final List<CardGridOption> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final bool multiSelect;

  /// При multiSelect: максимум выбранных (доп. выбор блокируется мягко).
  final int? maxSelect;
  final int columns;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: [
        for (final o in options)
          _Card(
            option: o,
            selected: selected.contains(o.key),
            dimmed: multiSelect &&
                maxSelect != null &&
                selected.length >= maxSelect! &&
                !selected.contains(o.key),
            onTap: () {
              HapticFeedback.selectionClick();
              onToggle(o.key);
            },
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.option,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  final CardGridOption option;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = option.tint ?? AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.20)
              : AppColors.bgCard.withValues(alpha: dimmed ? 0.4 : 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.06),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: dimmed ? 0.45 : 1,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? tint.withValues(alpha: 0.30)
                        : AppColors.bgElevated,
                  ),
                  child: Icon(
                    option.icon,
                    size: 24,
                    color: selected ? Colors.white : tint,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: dimmed
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
              if (option.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  option.description!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Широкая карточка-строка (для стилей поддержки и т.п.): иконка слева,
/// заголовок + описание, select-состояние как у грида.
class SelectableRowCard extends StatelessWidget {
  const SelectableRowCard({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CardGridOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = option.tint ?? AppColors.accent;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.20)
              : AppColors.bgCard.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.06),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.30),
                    blurRadius: 18,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? tint.withValues(alpha: 0.30)
                    : AppColors.bgElevated,
              ),
              child: Icon(
                option.icon,
                size: 20,
                color: selected ? Colors.white : tint,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (option.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      option.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}
