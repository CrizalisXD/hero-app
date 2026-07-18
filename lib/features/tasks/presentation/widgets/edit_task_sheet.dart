
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/notifications/widgets/reminder_sheet.dart';
import '../../application/tasks_notifier.dart';
import '../../domain/models/task.dart';

/// Bottom sheet for editing an existing task — opened from the swipe
/// "Edit" action. Scope is intentionally narrow: title, due date/time,
/// recurrence. Difficulty / duration / importance stay locked because
/// the classifier produced them and changing them would also have to
/// recompute XP — out of scope for an inline edit.
class EditTaskSheet extends ConsumerStatefulWidget {
  const EditTaskSheet({super.key, required this.task});

  final Task task;

  static Future<Task?> show(BuildContext context, Task task) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditTaskSheet(task: task),
    );
  }

  @override
  ConsumerState<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends ConsumerState<EditTaskSheet> {
  late final TextEditingController _titleCtrl;
  late DateTime? _dueAt;
  late bool _isRecurring;
  late String _recurrence;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _dueAt = widget.task.dueAt;
    _isRecurring = widget.task.isRecurring;
    _recurrence = widget.task.recurrence ?? 'daily';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

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
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (time == null || !mounted) return;
    setState(() {
      _dueAt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute,
      );
    });
  }

  static String _formatDueAt(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} '
        '${two(d.hour)}:${two(d.minute)}';
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _submitting) return;

    setState(() => _submitting = true);

    final updatedTask = widget.task.copyWith(
      title: title,
      dueAt: _dueAt,
      dueDate: _dueAt,
      isRecurring: _isRecurring,
      recurrence: _isRecurring ? _recurrence : null,
    );

    final result =
        await ref.read(tasksNotifierProvider.notifier).updateTask(updatedTask);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      Navigator.of(context).pop(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.taskEditError)),
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
                  l.taskEditTitle,
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
            decoration: InputDecoration(
              hintText: l.tasksCreateHint,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.event, color: theme.hintColor, size: 18),
              const SizedBox(width: 8),
              Text(
                l.createTaskDueDateLabel,
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              if (_dueAt != null)
                TextButton(
                  onPressed: () => setState(() => _dueAt = null),
                  child: Text(l.createTaskDueDateClear),
                ),
              TextButton(
                onPressed: _pickDueAt,
                child: Text(_dueAt == null ? '—' : _formatDueAt(_dueAt!)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(Icons.notifications_none, color: theme.hintColor),
            title: Text(l.reminderSheetTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ReminderSheet.show(
              context,
              entityType: 'task',
              entityId: widget.task.id,
              entityTitle: _titleCtrl.text.trim().isEmpty
                  ? widget.task.title
                  : _titleCtrl.text.trim(),
              dueAt: _dueAt,
            ),
          ),
          const SizedBox(height: 4),
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
          if (_isRecurring) ...[
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
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _submitting ? null : _save,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l.taskEditSave),
          ),
        ],
      ),
    );
  }
}
