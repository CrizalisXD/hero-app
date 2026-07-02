import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../energy/data/energy_service.dart';
import '../../../energy/presentation/energy_guard.dart';
import '../../application/goal_creation_notifier.dart';
import '../../application/goals_notifier.dart';
import '../../domain/models/ai_plan_step.dart';
import '../../domain/models/goal_plan_mode.dart';

class GoalPlanReviewScreen extends ConsumerWidget {
  const GoalPlanReviewScreen({super.key});

  /// Go back to the create form. Prefer popping the pushed review screen (keeps
  /// the form beneath it with a working back button) — only fall back to the
  /// goals list if there's nothing to pop, so the user can never get stranded
  /// on a back-button-less screen.
  void _backToForm(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/goals');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(goalCreationProvider);

    // Idle here means the user opened /goals/review without first
    // filling in the form — bounce them back. Analyzing, on the other
    // hand, is what we want to show *on this screen* when the user hits
    // "Regenerate" — keep them in place with a loading overlay instead
    // of yanking them back to the form.
    if (state is GoalCreationIdle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) _backToForm(context);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state is GoalCreationAnalyzing) {
      return Scaffold(
        appBar: AppBar(title: Text(l.goalPlanReviewTitle)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l.goalAnalyzing),
            ],
          ),
        ),
      );
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
                HeroButton(
                  label: l.goalPlanReviewBack,
                  variant: HeroButtonVariant.secondary,
                  fullWidth: false,
                  onPressed: () => _backToForm(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is GoalCreationDone) {
      // Confirmed — land the user on the goals LIST (per product: after
      // creating a goal, exit the create flow to the list, not deeper into a
      // detail screen). `go('/goals')` also collapses the pushed
      // /goals/new + /goals/review stack, so there's no way back into the
      // half-finished flow.
      //
      // Navigate FIRST, then reset the state machine on a delay so the reset
      // (which flips state to Idle) lands after this screen has unmounted —
      // otherwise the Idle branch above could fire a competing redirect.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ref.read(goalsNotifierProvider.notifier).onGoalCreated();
        context.go('/goals');
        Future.delayed(const Duration(milliseconds: 250), () {
          ref.read(goalCreationProvider.notifier).reset();
        });
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // We have a plan: either Review or Confirming.
    final isConfirming = state is GoalCreationConfirming;
    final plan = state is GoalCreationReview
        ? state.plan
        : (state as GoalCreationConfirming).plan;
    final planMode =
        state is GoalCreationReview ? state.answers.planMode : GoalPlanMode.ai;
    final isManual =
        planMode == GoalPlanMode.own || planMode == GoalPlanMode.mixed;
    final canRegenerate = planMode != GoalPlanMode.own;
    final enabledStepCount = plan.steps.where((s) => s.enabled).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.goalPlanReviewTitle),
        leading: isConfirming
            ? null
            : BackButton(onPressed: () => _backToForm(context)),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Summary ───────────────────────────────────────────
              if (plan.summary.isNotEmpty) ...[
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
              ],

              // ── Steps ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.goalPlanReviewSteps,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (isManual && !isConfirming)
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l.goalPlanAddStep),
                      onPressed: () => _showAddStepSheet(context, ref),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (plan.steps.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      l.goalPlanEmptyOwn,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
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
                  onDelete: (isManual && !isConfirming)
                      ? () => ref
                          .read(goalCreationProvider.notifier)
                          .removeStep(idx)
                      : null,
                );
              }),

              const SizedBox(height: 32),

              // ── Actions ───────────────────────────────────────────
              HeroButton(
                label: l.goalPlanReviewConfirm,
                isLoading: isConfirming,
                onPressed: (isConfirming || enabledStepCount == 0)
                    ? null
                    : () async {
                        // Energy gate before we materialise the plan
                        // server-side. Cost is fixed at the goal tier;
                        // the AI-generated sub-tasks and habits don't
                        // each charge separately (would double-bill).
                        final paid = await EnergyGuard.spendOrBlock(
                          context,
                          ref,
                          EnergyCosts.goal,
                        );
                        if (!paid || !context.mounted) return;
                        await ref.read(goalCreationProvider.notifier).confirm();
                      },
              ),
              if (canRegenerate) ...[
                const SizedBox(height: 12),
                HeroButton(
                  label: l.goalPlanReviewRegenerate,
                  variant: HeroButtonVariant.secondary,
                  onPressed: isConfirming
                      ? null
                      : () =>
                          ref.read(goalCreationProvider.notifier).regenerate(),
                ),
              ],
              const SizedBox(height: 8),
              HeroButton(
                label: l.goalPlanReviewBack,
                variant: HeroButtonVariant.ghost,
                onPressed: isConfirming ? null : () => _backToForm(context),
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
    this.onDelete,
  });

  final AiPlanStep step;
  final bool enabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onDelete;

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
        secondary: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : null,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

// ── Add-step sheet (own / mixed modes) ───────────────────────────────────────

Future<void> _showAddStepSheet(BuildContext context, WidgetRef ref) async {
  final step = await showModalBottomSheet<AiPlanStep>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AddStepSheet(),
  );
  if (step != null) {
    ref.read(goalCreationProvider.notifier).addStep(step);
  }
}

class _AddStepSheet extends StatefulWidget {
  const _AddStepSheet();

  @override
  State<_AddStepSheet> createState() => _AddStepSheetState();
}

class _AddStepSheetState extends State<_AddStepSheet> {
  final _titleCtrl = TextEditingController();
  AiPlanStepType _type = AiPlanStepType.task;
  String _frequency = 'daily';

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final step = AiPlanStep(
      type: _type,
      title: title,
      frequency: _type == AiPlanStepType.habit ? _frequency : null,
      difficulty: _type == AiPlanStepType.habit ? 'easy' : 'normal',
      duration: _type == AiPlanStepType.habit ? 'short' : 'medium',
      xpReward: _type == AiPlanStepType.milestone ? 50 : 20,
    );
    Navigator.of(context).pop(step);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.goalPlanAddStep,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.goalPlanStepTitleLabel),
          ),
          const SizedBox(height: 16),
          Text(l.goalPlanStepTypeLabel,
              style: Theme.of(context).textTheme.bodySmall,),
          const SizedBox(height: 8),
          SegmentedButton<AiPlanStepType>(
            segments: [
              ButtonSegment(
                value: AiPlanStepType.task,
                label: Text(l.goalPlanStepTask),
              ),
              ButtonSegment(
                value: AiPlanStepType.habit,
                label: Text(l.goalPlanStepHabit),
              ),
              ButtonSegment(
                value: AiPlanStepType.milestone,
                label: Text(l.goalPlanStepMilestone),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          if (_type == AiPlanStepType.habit) ...[
            const SizedBox(height: 16),
            Text(l.goalPlanFrequencyLabel,
                style: Theme.of(context).textTheme.bodySmall,),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'daily',
                  label: Text(l.createTaskRecurringDaily),
                ),
                ButtonSegment(
                  value: 'weekly',
                  label: Text(l.createTaskRecurringWeekly),
                ),
              ],
              selected: {_frequency},
              onSelectionChanged: (s) => setState(() => _frequency = s.first),
            ),
          ],
          const SizedBox(height: 24),
          HeroButton(label: l.commonSave, onPressed: _save),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
