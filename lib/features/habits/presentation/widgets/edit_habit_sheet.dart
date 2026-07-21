import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/habits_notifier.dart';
import '../../domain/models/habit.dart';

/// Bottom sheet for editing an existing habit. Scope is intentionally narrow —
/// title + description only — mirroring [EditTaskSheet]. Category, difficulty
/// and XP stay as the classifier set them (changing them would mean recomputing
/// rewards), and editing never spends energy the way creating does.
class EditHabitSheet extends ConsumerStatefulWidget {
  const EditHabitSheet({super.key, required this.habit});

  final Habit habit;

  static Future<Habit?> show(BuildContext context, Habit habit) {
    return showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (_) => EditHabitSheet(habit: habit),
    );
  }

  @override
  ConsumerState<EditHabitSheet> createState() => _EditHabitSheetState();
}

class _EditHabitSheetState extends ConsumerState<EditHabitSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.habit.title);
    _descCtrl = TextEditingController(text: widget.habit.description ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting) return;

    setState(() => _submitting = true);

    final desc = _descCtrl.text.trim();
    final updated = await ref.read(habitsNotifierProvider.notifier).updateHabit(
          widget.habit.id,
          title: title,
          description: desc.isEmpty ? null : desc,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (updated != null) {
      Navigator.of(context).pop(updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.habitEditError)),
      );
    }
  }

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
          Row(
            children: [
              Expanded(
                child: Text(
                  l.habitEditTitle,
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
            autofocus: true,
            decoration: InputDecoration(
              labelText: l.createHabitTitleLabel,
              border: const OutlineInputBorder(),
            ),
            maxLength: 140,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descCtrl,
            decoration: InputDecoration(
              labelText: l.createHabitDescriptionLabel,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
            maxLength: 500,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed:
                (_submitting || _titleCtrl.text.trim().isEmpty) ? null : _save,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l.commonSave),
          ),
        ],
      ),
    );
  }
}
