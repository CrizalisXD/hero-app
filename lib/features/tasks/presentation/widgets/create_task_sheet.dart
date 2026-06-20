import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../categories/application/category_classifier_service.dart';
import '../../../categories/application/xp_engine.dart';
import '../../../categories/data/categories_assets_repository.dart';
import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';
import '../../../energy/data/energy_service.dart';
import '../../../energy/presentation/energy_guard.dart';
import '../../application/tasks_notifier.dart';
import '../../domain/models/create_task_input.dart';
import 'category_chip.dart';

class CreateTaskSheet extends ConsumerStatefulWidget {
  const CreateTaskSheet({super.key});

  @override
  ConsumerState<CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends ConsumerState<CreateTaskSheet> {
  final _titleCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  // No initial category — chip is hidden until classifier is confident.
  EnrichedClassification? _classification;
  bool _classifying = false;
  bool _submitting = false;
  DateTime? _dueAt;
  bool _isRecurring = false;
  String _recurrence = 'daily';

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(_onTitleChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _titleCtrl.removeListener(_onTitleChanged);
    _titleCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── title change ──────────────────────────────────────────────────────────

  void _onTitleChanged() {
    _debounce?.cancel();
    if (_titleCtrl.text.trim().length < 3) {
      setState(() {
        _classification = null;
        _classifying = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), _classify);
  }

  Future<void> _classify() async {
    final text = _titleCtrl.text.trim();
    final svc = ref.read(categoryClassifierServiceProvider).valueOrNull;
    if (svc == null || !mounted) return;

    setState(() => _classifying = true);

    final locale = Supabase.instance.client.auth.currentUser
            ?.userMetadata?['locale'] as String? ??
        'ru';
    final result =
        await svc.classify(text: text, entityType: 'task', locale: locale);

    if (!mounted) return;
    setState(() {
      _classification = result;
      _classifying = false;
    });
  }

  // ─── date-time picker ──────────────────────────────────────────────────────

  Future<void> _pickDueAt() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _dueAt ?? now.add(const Duration(hours: 1)),
      ),
      // Skip the analog dial — user feedback was that it's clumsy on iOS.
      // Force the digital input mode. The dial button stays visible in
      // the dialog for users who do prefer it.
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null || !mounted) return;
    setState(() {
      _dueAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  static const _monthsShort = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  static String _formatDueAt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    final now = DateTime.now();
    final isToday =
        d.year == now.year && d.month == now.month && d.day == now.day;
    final time = '${two(d.hour)}:${two(d.minute)}';
    if (isToday) return time;
    return '${d.day} ${_monthsShort[d.month - 1]}, $time';
  }

  // ─── submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting) return;

    final engine = ref.read(xpEngineProvider).valueOrNull;
    final cls = _classification;

    // §15.1: category always auto; fallback = mind (server-side default only).
    final mainCategory =
        (cls != null && cls.isConfident) ? cls.mainCategory : CategoryId.mind;
    final secondaries =
        (cls != null && cls.isConfident) ? cls.secondaryCategories : <CategoryId>[];

    final difficulty = cls?.suggestedDifficulty ?? TaskDifficulty.normal;
    final duration = cls?.suggestedDuration ?? TaskDuration.medium;
    final importance = cls?.suggestedImportance ?? TaskImportance.normal;
    final disciplineXp = cls?.suggestedDisciplineXp ?? 0;

    final rulesBundle = ref.read(categoryRulesProvider).valueOrNull;
    final int baseXp = rulesBundle?.rulesFor(mainCategory)?.baseXp ??
        rulesBundle?.defaultBaseXp ??
        20;

    final int xpReward = engine?.categoryXp(
          baseXp: baseXp,
          difficulty: difficulty,
          duration: duration,
          importance: importance,
        ) ??
        baseXp;

    // Energy gate — spend BEFORE we set _submitting=true so the user
    // can keep editing if they don't have enough.
    final cost = EnergyCosts.forTaskDifficulty(difficulty.wire);
    final paid = await EnergyGuard.spendOrBlock(context, ref, cost);
    if (!paid) return;
    if (!mounted) return;

    setState(() => _submitting = true);

    final input = CreateTaskInput(
      title: title,
      mainCategory: mainCategory,
      secondaryCategories: secondaries,
      difficulty: difficulty,
      duration: duration,
      importance: importance,
      xpReward: xpReward,
      disciplineXpReward: disciplineXp,
      dueAt: _dueAt,
      isRecurring: _isRecurring,
      recurrence: _isRecurring ? _recurrence : null,
    );

    final task =
        await ref.read(tasksNotifierProvider.notifier).createTask(input);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (task != null) {
      unawaited(ref.read(todayTasksNotifierProvider.notifier).refresh());
      if (context.mounted) Navigator.of(context).pop(task);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.taskCreateError)),
        );
      }
    }
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l.createTask,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title field
          TextField(
            controller: _titleCtrl,
            focusNode: _focusNode,
            decoration: InputDecoration(hintText: l.tasksCreateHint),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 10),

          // Category row — placeholder / spinner / chip
          _buildCategoryRow(l),
          const SizedBox(height: 10),

          // Due date row
          _buildDueDateRow(l, theme),
          const SizedBox(height: 4),

          // Recurring toggle — "повторяющиеся задачи" = чистить зубы,
          // выкинуть мусор. Не привычка (нет стрика), просто авто-копия
          // на следующий день/неделю при выполнении.
          _buildRecurringRow(l, theme),
          const SizedBox(height: 14),

          // Submit
          HeroButton(
            label: l.createTask,
            icon: Icons.add_task,
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(AppLocalizations l) {
    final text = _titleCtrl.text.trim();

    // 1) Text too short
    if (text.length < 3) {
      return _hintText(l.createTaskCategoryUnclear);
    }

    // 2) Classifier running
    if (_classifying) {
      return Row(
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          _hintText(l.createTaskCategoryDetecting),
        ],
      );
    }

    final c = _classification;

    // 3) Classifier ran but not confident (fallback) — no chip
    if (c == null || !c.isConfident) {
      return _hintText(l.createTaskCategoryUnclear);
    }

    // 4) Confident — show main + secondaries
    return Row(
      children: [
        CategoryChip(category: c.mainCategory),
        for (final s in c.secondaryCategories) ...[
          const SizedBox(width: 6),
          CategoryChip(category: s, fontSize: 11),
        ],
      ],
    );
  }

  Widget _buildDueDateRow(AppLocalizations l, ThemeData theme) {
    final hasDate = _dueAt != null;
    return Row(
      children: [
        Icon(Icons.event, color: theme.hintColor, size: 18),
        const SizedBox(width: 8),
        Text(l.createTaskDueDateLabel, style: theme.textTheme.bodySmall),
        const Spacer(),
        if (hasDate)
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            color: AppColors.textMuted,
            icon: const Icon(Icons.close),
            tooltip: l.createTaskDueDateClear,
            onPressed: () => setState(() => _dueAt = null),
          ),
        InkWell(
          onTap: _pickDueAt,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: hasDate ? AppColors.accentDim : AppColors.bgElevated,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: hasDate
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasDate ? Icons.schedule : Icons.add,
                  size: 15,
                  color: hasDate ? AppColors.accent : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  hasDate ? _formatDueAt(_dueAt!) : l.createTaskDueDateLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasDate ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringRow(AppLocalizations l, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: _isRecurring,
          onChanged: (v) => setState(() => _isRecurring = v),
          title: Row(
            children: [
              Icon(Icons.repeat, color: theme.hintColor, size: 18),
              const SizedBox(width: 8),
              Text(
                l.createTaskRecurring,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (_isRecurring)
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
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
                  selected: {_recurrence},
                  onSelectionChanged: (set) =>
                      setState(() => _recurrence = set.first),
                ),
                const SizedBox(height: 6),
                Text(
                  l.createTaskRecurringHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Widget _hintText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0x80FFFFFF),
        ),
      );
}
