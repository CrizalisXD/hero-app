import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../application/goal_creation_notifier.dart';
import '../../application/goals_notifier.dart';
import '../../domain/models/ai_plan_step.dart';

class GoalPlanReviewScreen extends ConsumerWidget {
  const GoalPlanReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(goalCreationProvider);

    // Resolve the plan regardless of whether we're in Review or Confirming.
    // Both states carry the plan; Confirming shows a loading overlay.
    if (state is GoalCreationIdle || state is GoalCreationAnalyzing) {
      // Navigated here without going through create screen — go back.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/goals/new');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state is GoalCreationError) {
      return Scaffold(
        appBar: AppBar(title: Text(l.goalPlanReviewTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.goalConfirmError, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.go('/goals/new'),
                  child: Text(l.goalPlanReviewBack),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is GoalCreationDone) {
      // Confirmed — navigate to goals list.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ref.read(goalsNotifierProvider.notifier).onGoalCreated();
          ref.read(goalCreationProvider.notifier).reset();
          context.go('/goals');
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // We have a plan: either Review or Confirming.
    final isConfirming = state is GoalCreationConfirming;
    final plan = state is GoalCreationReview
        ? state.plan
        : (state as GoalCreationConfirming).plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalPlanReviewTitle),
        leading: isConfirming
            ? null
            : BackButton(onPressed: () => context.go('/goals/new')),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary ───────────────────────────────────────────
              Text(
                l.goalPlanReviewSummary,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(plan.summary),
              if (plan.estimatedWeeks != null) ...[
                const SizedBox(height: 8),
                Text(
                  l.goalPlanReviewEstimated(plan.estimatedWeeks!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),

              // ── Steps ──────────────────────────────────────────────
              Text(
                l.goalPlanReviewSteps,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...plan.steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final step = entry.value;
                return _StepTile(
                  step: step,
                  enabled: step.enabled,
                  onToggle: isConfirming
                      ? null
                      : (v) => ref
                          .read(goalCreationProvider.notifier)
                          .toggleStep(idx, enabled: v),
                );
              }),

              const SizedBox(height: 32),

              // ── Actions ───────────────────────────────────────────
              FilledButton(
                onPressed: isConfirming
                    ? null
                    : () =>
                        ref.read(goalCreationProvider.notifier).confirm(),
                child: isConfirming
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.goalPlanReviewConfirm),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: isConfirming
                    ? null
                    : () => ref
                        .read(goalCreationProvider.notifier)
                        .regenerate(),
                child: Text(l.goalPlanReviewRegenerate),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    isConfirming ? null : () => context.go('/goals/new'),
                child: Text(l.goalPlanReviewBack),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Confirming overlay
          if (isConfirming)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Step tile ──────────────────────────────────────────────────────────────

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.step,
    required this.enabled,
    required this.onToggle,
  });

  final AiPlanStep step;
  final bool enabled;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final typeLabel = switch (step.type) {
      AiPlanStepType.task => l.goalPlanStepTask,
      AiPlanStepType.habit => l.goalPlanStepHabit,
      AiPlanStepType.milestone => l.goalPlanStepMilestone,
    };
    final typeColor = switch (step.type) {
      AiPlanStepType.task => Colors.blue,
      AiPlanStepType.habit => Colors.green,
      AiPlanStepType.milestone => Colors.amber.shade700,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: enabled,
        onChanged: onToggle != null ? (v) => onToggle!(v ?? false) : null,
        controlAffinity: ListTileControlAffinity.leading,
        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel,
                style: TextStyle(fontSize: 10, color: typeColor),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                step.title,
                style: enabled
                    ? null
                    : const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
              ),
            ),
          ],
        ),
        subtitle: step.description != null && step.description!.isNotEmpty
            ? Text(
                step.description!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              )
            : null,
      ),
    );
  }
}
