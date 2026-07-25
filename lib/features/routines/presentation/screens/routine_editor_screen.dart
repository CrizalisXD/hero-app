import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../application/routines_notifier.dart';
import '../../domain/models/routine.dart';
import '../../domain/models/routine_inputs.dart';

/// Stable notification id derived from the routine's UUID.
int routineNotifId(String routineId) => routineId.hashCode & 0x7fffffff;

class _StepDraft {
  _StepDraft({String title = '', String minutes = ''})
      : titleCtrl = TextEditingController(text: title),
        minutesCtrl = TextEditingController(text: minutes);
  final TextEditingController titleCtrl;
  final TextEditingController minutesCtrl;

  void dispose() {
    titleCtrl.dispose();
    minutesCtrl.dispose();
  }
}

class RoutineEditorScreen extends ConsumerStatefulWidget {
  const RoutineEditorScreen({super.key, this.routine});

  /// Null → create; non-null → edit.
  final Routine? routine;

  @override
  ConsumerState<RoutineEditorScreen> createState() =>
      _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends ConsumerState<RoutineEditorScreen> {
  late final TextEditingController _titleCtrl;
  final List<_StepDraft> _steps = [];
  bool _reminder = false;
  TimeOfDay? _time;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.routine;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _reminder = r?.reminderEnabled ?? false;
    _time = _parseTime(r?.scheduledTime);
    if (r != null && r.steps.isNotEmpty) {
      for (final s in r.steps) {
        _steps.add(
          _StepDraft(
            title: s.title,
            minutes: s.durationMinutes?.toString() ?? '',
          ),
        );
      }
    } else {
      _steps.add(_StepDraft());
    }
  }

  static TimeOfDay? _parseTime(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    for (final s in _steps) {
      s.dispose();
    }
    super.dispose();
  }

  String? _timeString() {
    final t = _time;
    if (t == null) return null;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty || _saving) return;

    final steps = <RoutineStepInput>[];
    for (final s in _steps) {
      final t = s.titleCtrl.text.trim();
      if (t.isEmpty) continue;
      steps.add(
        RoutineStepInput(
          title: t,
          durationMinutes: int.tryParse(s.minutesCtrl.text.trim()),
        ),
      );
    }
    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.routineNeedsSteps)),
      );
      return;
    }

    setState(() => _saving = true);

    final input = RoutineInput(
      title: title,
      scheduledTime: _reminder ? _timeString() : null,
      reminderEnabled: _reminder && _time != null,
      steps: steps,
    );

    final notifier = ref.read(routinesNotifierProvider.notifier);
    final Routine? saved = widget.routine == null
        ? await notifier.createRoutine(input)
        : await notifier.updateRoutine(widget.routine!.id, input);

    if (!mounted) return;
    setState(() => _saving = false);

    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.routineSaveError)),
      );
      return;
    }

    await _syncReminder(saved);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _syncReminder(Routine saved) async {
    final svc = LocalNotificationsService.instance;
    final id = routineNotifId(saved.id);
    if (saved.reminderEnabled && _time != null) {
      await svc.scheduleRoutineReminder(
        id: id,
        title: saved.title,
        body: context.l10n.routineCompleteAction,
        at: _time!,
      );
    } else {
      await svc.cancelReminder(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.routine == null ? l.routineCreateTitle : l.routineEditTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: l.routineTitleLabel,
              hintText: l.routineTitleHint,
              border: const OutlineInputBorder(),
            ),
            maxLength: 60,
          ),
          const SizedBox(height: 8),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l.routineReminderToggle),
            secondary: const Icon(Icons.notifications_none),
            value: _reminder,
            onChanged: (v) => setState(() => _reminder = v),
          ),
          if (_reminder)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 16),
              leading: const Icon(Icons.schedule),
              title: Text(l.routineTimeLabel),
              trailing: TextButton(
                onPressed: _pickTime,
                child: Text(_time == null ? '—' : _time!.format(context)),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            l.routineStepsLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _steps.length; i++) _stepRow(l, i),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: () => setState(() => _steps.add(_StepDraft())),
            icon: const Icon(Icons.add),
            label: Text(l.routineAddStep),
          ),
          const SizedBox(height: 16),
          HeroButton(
            label: l.commonSave,
            isLoading: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _stepRow(AppLocalizations l, int i) {
    final s = _steps[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: s.titleCtrl,
              decoration: InputDecoration(
                isDense: true,
                hintText: l.routineStepTitleHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: TextField(
              controller: s.minutesCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                hintText: l.routineStepMinutesHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textMuted),
            onPressed: _steps.length <= 1
                ? null
                : () => setState(() {
                      _steps.removeAt(i).dispose();
                    }),
          ),
        ],
      ),
    );
  }
}
