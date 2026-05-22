import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../categories/application/category_classifier_service.dart';
import '../../../categories/application/xp_engine.dart';
import '../../../categories/data/categories_assets_repository.dart';
import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/xp_inputs.dart';
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

  CategoryId _detectedCategory = CategoryId.mind;
  EnrichedClassification? _classification;
  bool _classifying = false;
  bool _submitting = false;

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

  void _onTitleChanged() {
    _debounce?.cancel();
    final text = _titleCtrl.text.trim();
    if (text.length < 3) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _classify(text));
  }

  Future<void> _classify(String text) async {
    final svc = ref.read(categoryClassifierServiceProvider).valueOrNull;
    if (svc == null) return;
    if (!mounted) return;

    setState(() => _classifying = true);

    final locale = Supabase.instance.client.auth.currentUser
            ?.userMetadata?['locale'] as String? ??
        'ru';
    final result =
        await svc.classify(text: text, entityType: 'task', locale: locale);

    if (!mounted) return;
    setState(() {
      _classification = result;
      _detectedCategory = result.mainCategory;
      _classifying = false;
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting) return;

    setState(() => _submitting = true);

    final engine = ref.read(xpEngineProvider).valueOrNull;
    final cls = _classification;

    final difficulty = cls?.suggestedDifficulty ?? TaskDifficulty.normal;
    final duration = cls?.suggestedDuration ?? TaskDuration.medium;
    final importance = cls?.suggestedImportance ?? TaskImportance.normal;
    final disciplineXp = cls?.suggestedDisciplineXp ?? 0;

    final rulesBundle =
        ref.read(categoryRulesProvider).valueOrNull;
    final int baseXp = rulesBundle?.rulesFor(_detectedCategory)?.baseXp ??
        rulesBundle?.defaultBaseXp ??
        20;

    final int xpReward = engine?.categoryXp(
          baseXp: baseXp,
          difficulty: difficulty,
          duration: duration,
          importance: importance,
        ) ??
        baseXp;

    final input = CreateTaskInput(
      title: title,
      mainCategory: _detectedCategory,
      secondaryCategories: cls?.secondaryCategories ?? [],
      difficulty: difficulty,
      duration: duration,
      importance: importance,
      xpReward: xpReward,
      disciplineXpReward: disciplineXp,
    );

    final task =
        await ref.read(tasksNotifierProvider.notifier).createTask(input);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (task != null) {
      // Keep Today list in sync — fire-and-forget, we don't block on it.
      unawaited(ref.read(todayTasksNotifierProvider.notifier).refresh());
      Navigator.of(context).pop(task);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskCreateError)),
      );
    }
  }

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
          TextField(
            controller: _titleCtrl,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: l.tasksCreateHint,
              border: const OutlineInputBorder(),
              suffixIcon: _classifying
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: CategoryChip(
                  key: ValueKey(_detectedCategory),
                  category: _detectedCategory,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l.createTask),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
