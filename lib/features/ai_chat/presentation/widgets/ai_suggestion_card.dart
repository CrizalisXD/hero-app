import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../categories/application/xp_engine.dart';
import '../../../categories/domain/models/xp_inputs.dart';
import '../../../habits/application/habits_notifier.dart';
import '../../../habits/domain/models/create_habit_input.dart';
import '../../../tasks/application/tasks_notifier.dart';
import '../../../tasks/domain/models/create_task_input.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../domain/models/ai_suggestion.dart';

class AiSuggestionCard extends ConsumerStatefulWidget {
  const AiSuggestionCard({super.key, required this.suggestion});
  final AiSuggestion suggestion;

  @override
  ConsumerState<AiSuggestionCard> createState() =>
      _AiSuggestionCardState();
}

class _AiSuggestionCardState extends ConsumerState<AiSuggestionCard> {
  bool _added = false;
  bool _dismissed = false;
  bool _busy = false;

  Future<void> _add() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final engine = await ref.read(xpEngineProvider.future);
      final main = widget.suggestion.mainCategory;

      if (widget.suggestion.type == AiSuggestionType.task) {
        final xp = engine.categoryXp(
          baseXp: 30,
          difficulty: TaskDifficulty.normal,
          duration: TaskDuration.medium,
          importance: TaskImportance.normal,
        );
        final input = CreateTaskInput(
          title: widget.suggestion.title,
          mainCategory: main,
          difficulty: TaskDifficulty.normal,
          duration: TaskDuration.medium,
          importance: TaskImportance.normal,
          xpReward: xp,
          disciplineXpReward: 0,
        );
        final task =
            await ref.read(tasksNotifierProvider.notifier).createTask(input);
        if (mounted && task != null) setState(() => _added = true);
      } else {
        final xp = engine.categoryXp(
          baseXp: 20,
          difficulty: TaskDifficulty.easy,
          duration: TaskDuration.short,
          importance: TaskImportance.normal,
        );
        final input = CreateHabitInput(
          title: widget.suggestion.title,
          mainCategory: main,
          difficulty: TaskDifficulty.easy,
          duration: TaskDuration.short,
          importance: TaskImportance.normal,
          xpReward: xp,
          disciplineXpReward: engine.disciplineXpForHabit(),
        );
        final habit = await ref
            .read(habitsNotifierProvider.notifier)
            .createHabit(input);
        if (mounted && habit != null) setState(() => _added = true);
      }
    } catch (_) {
      // Silently ignore — user can retry
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();
    final l = context.l10n;
    final isTask = widget.suggestion.type == AiSuggestionType.task;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isTask
                      ? l.aiSuggestionTaskBadge
                      : l.aiSuggestionHabitBadge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              CategoryChip(category: widget.suggestion.mainCategory),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.suggestion.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!_added) ...[
                TextButton(
                  onPressed:
                      _busy ? null : () => setState(() => _dismissed = true),
                  child: Text(l.aiSuggestionDismiss),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _busy ? null : _add,
                  child: _busy
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l.aiSuggestionAdd),
                ),
              ] else
                const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'OK',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
