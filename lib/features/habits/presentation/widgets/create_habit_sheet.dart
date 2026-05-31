import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../categories/application/category_classifier_service.dart';
import '../../../categories/application/xp_engine.dart';
import '../../../categories/data/categories_assets_repository.dart';
import '../../../categories/domain/models/category_id.dart';
import '../../../categories/domain/models/category_rules.dart';
import '../../../categories/domain/models/xp_inputs.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../application/habits_notifier.dart';
import '../../domain/models/create_habit_input.dart';

class CreateHabitSheet extends ConsumerStatefulWidget {
  const CreateHabitSheet({super.key});

  /// Convenience factory — opens the sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const CreateHabitSheet(),
      ),
    );
  }

  @override
  ConsumerState<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends ConsumerState<CreateHabitSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

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
    _descCtrl.dispose();
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
    final CategoryClassifierService? svc =
        ref.read(categoryClassifierServiceProvider).valueOrNull;
    if (svc == null || !mounted) return;

    setState(() => _classifying = true);

    final locale = Supabase.instance.client.auth.currentUser
            ?.userMetadata?['locale'] as String? ??
        'ru';
    final result =
        await svc.classify(text: text, entityType: 'habit', locale: locale);

    if (!mounted) return;
    setState(() {
      _classification = result;
      _classifying = false;
    });
  }

  // ─── submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting) return;

    setState(() => _submitting = true);

    final XpEngine? engine = ref.read(xpEngineProvider).valueOrNull;
    final CategoryRulesBundle? rulesBundle =
        ref.read(categoryRulesProvider).valueOrNull;
    final cls = _classification;

    final main =
        (cls != null && cls.isConfident) ? cls.mainCategory : CategoryId.mind;
    final secondaries =
        (cls != null && cls.isConfident) ? cls.secondaryCategories : <CategoryId>[];

    final difficulty = cls?.suggestedDifficulty ?? TaskDifficulty.easy;
    final duration = cls?.suggestedDuration ?? TaskDuration.short;
    final importance = cls?.suggestedImportance ?? TaskImportance.normal;

    final int baseXp = rulesBundle?.rulesFor(main)?.baseXp ??
        rulesBundle?.defaultBaseXp ??
        20;

    final int xpReward = engine?.categoryXp(
          baseXp: baseXp,
          difficulty: difficulty,
          duration: duration,
          importance: importance,
        ) ??
        baseXp;

    final int disciplineXp = cls?.suggestedDisciplineXp ??
        engine?.disciplineXpForHabit() ??
        4;

    final input = CreateHabitInput(
      title: title,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      mainCategory: main,
      secondaryCategories: secondaries,
      difficulty: difficulty,
      duration: duration,
      importance: importance,
      xpReward: xpReward,
      disciplineXpReward: disciplineXp,
    );

    final habit =
        await ref.read(habitsNotifierProvider.notifier).createHabit(input);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (habit != null) {
      if (context.mounted) Navigator.of(context).pop();
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.createHabitCreateError)),
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
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l.createHabitSheetTitle,
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
            decoration: InputDecoration(
              labelText: l.createHabitTitleLabel,
              hintText: l.createHabitTitleHint,
              border: const OutlineInputBorder(),
            ),
            maxLength: 140,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),

          // Category row
          _buildCategoryRow(l),
          const SizedBox(height: 12),

          // Description field (optional)
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: l.createHabitDescriptionLabel,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),

          // Submit
          FilledButton(
            onPressed: (_submitting || _titleCtrl.text.trim().isEmpty)
                ? null
                : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l.createHabitSubmit),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(AppLocalizations l) {
    final text = _titleCtrl.text.trim();

    if (text.length < 3) {
      return _hintText(l.createTaskCategoryUnclear);
    }

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
    if (c == null || !c.isConfident) {
      return _hintText(l.createTaskCategoryUnclear);
    }

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

  static Widget _hintText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0x80FFFFFF),
        ),
      );
}
