import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/l10n.dart';
import '../application/onboarding_controller.dart';
import 'widgets/onboarding_shell.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(ref.read(onboardingControllerProvider).starterHabits);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final habits = [
      (
        key: 'drink_water',
        label: l.onboardingHabitDrinkWater,
        icon: Icons.water_drop_outlined,
        color: AppColors.health,
      ),
      (
        key: 'read_10_pages',
        label: l.onboardingHabitRead10,
        icon: Icons.menu_book_outlined,
        color: AppColors.mind,
      ),
      (
        key: 'walk_10_min',
        label: l.onboardingHabitWalk10,
        icon: Icons.directions_walk_outlined,
        color: AppColors.endurance,
      ),
    ];

    return OnboardingShell(
      step: 7,
      totalSteps: 9,
      title: l.onboardingHabitsTitle,
      subtitle: l.onboardingHabitsSubtitle,
      onBack: () => context.go('/onboarding/support-style'),
      onContinue: () {
        ref
            .read(onboardingControllerProvider.notifier)
            .setStarterHabits(_selected.toList());
        context.go('/onboarding/avatar-intro');
      },
      content: Column(
        children: habits.map((h) {
          final isSelected = _selected.contains(h.key);
          return GestureDetector(
            onTap: () => setState(() {
              if (_selected.contains(h.key)) {
                _selected.remove(h.key);
              } else {
                _selected.add(h.key);
              }
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? h.color.withValues(alpha: 0.12)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? h.color : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: h.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(h.icon, color: h.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      h.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: h.color, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
