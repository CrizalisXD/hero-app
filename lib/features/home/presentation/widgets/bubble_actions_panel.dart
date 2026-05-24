import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';

class BubbleActionsPanel extends StatelessWidget {
  const BubbleActionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = <_Bubble>[
      _Bubble(
        icon: Icons.task_alt,
        label: l.homeBubbleTasks,
        onTap: () => context.go('/tasks'),
      ),
      _Bubble(
        icon: Icons.local_fire_department,
        label: l.homeBubbleHabits,
        onTap: () => context.go('/habits'),
      ),
      _Bubble(
        icon: Icons.flag,
        label: l.homeBubbleGoals,
        onTap: () => context.go('/goals'),
      ),
      _Bubble(
        icon: Icons.smart_toy_outlined,
        label: l.homeBubbleCoach,
        onTap: () => context.go('/coach'),
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: items.map((b) => _BubbleView(bubble: b)).toList(),
    );
  }
}

class _Bubble {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _Bubble({required this.icon, required this.label, required this.onTap});
}

class _BubbleView extends StatelessWidget {
  const _BubbleView({required this.bubble});
  final _Bubble bubble;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: bubble.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          children: [
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(bubble.icon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(height: 6),
            Text(bubble.label, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
