import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../habits/domain/models/habit.dart';
import '../../../habits/presentation/widgets/streak_badge.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';

/// Lightweight habits preview with streak badges.
/// Tasks preview is already rendered in TodayFocusPanel.
class DailyTasksPreview extends StatelessWidget {
  const DailyTasksPreview({
    super.key,
    required this.habits,
    required this.checkedToday,
  });

  final List<Habit> habits;
  final Set<String> checkedToday;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    if (habits.isEmpty) return const SizedBox.shrink();

    final shown = habits.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l.navHabits,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/habits'),
                child: Text(l.homePreviewMore),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...shown.map((h) {
            final done = checkedToday.contains(h.id);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: done ? AppColors.success : AppColors.border,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      h.title,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  StreakBadge(days: h.currentStreak),
                  const SizedBox(width: 8),
                  CategoryChip(category: h.mainCategory),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
