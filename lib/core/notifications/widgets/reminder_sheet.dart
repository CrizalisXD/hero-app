import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../features/settings/data/notification_settings_repository.dart';
import '../entity_reminder.dart';
import '../local_notifications_service.dart';
import '../reminder_repository.dart';

/// Bottom sheet for configuring a reminder on a task / habit / goal.
///
/// Shared across features. For tasks with a [dueAt] it offers a one-shot
/// "remind me N minutes before"; for everything it offers a repeating
/// time-of-day reminder. Saving writes an `entity_reminders` row and schedules
/// the local notification (skipped silently if the type is muted or the time
/// lands inside quiet hours).
class ReminderSheet extends ConsumerStatefulWidget {
  const ReminderSheet({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityTitle,
    this.dueAt,
  });

  final String entityType; // 'task' | 'habit' | 'goal'
  final String entityId;
  final String entityTitle;
  final DateTime? dueAt;

  static Future<bool?> show(
    BuildContext context, {
    required String entityType,
    required String entityId,
    required String entityTitle,
    DateTime? dueAt,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReminderSheet(
        entityType: entityType,
        entityId: entityId,
        entityTitle: entityTitle,
        dueAt: dueAt,
      ),
    );
  }

  @override
  ConsumerState<ReminderSheet> createState() => _ReminderSheetState();
}

enum _Mode { once, repeating }

class _ReminderSheetState extends ConsumerState<ReminderSheet> {
  bool _loading = true;
  bool _saving = false;
  List<EntityReminder> _existing = const [];

  late _Mode _mode = widget.dueAt != null ? _Mode.once : _Mode.repeating;

  // One-shot: minutes before the due time (0 == at time of event).
  int _leadMinutes = 0;

  // Repeating
  TimeOfDay _timeOfDay = const TimeOfDay(hour: 9, minute: 0);
  ReminderRecurrence _recurrence = ReminderRecurrence.daily;
  int _weekday = DateTime.monday;

  bool get _hasDue => widget.dueAt != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ref.read(reminderRepositoryProvider).forEntity(
            entityType: widget.entityType,
            entityId: widget.entityId,
          );
      if (mounted) setState(() => _existing = list);
    } catch (_) {
      // Non-fatal: just show the create form.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _notifId =>
      notificationIdFor(widget.entityId, widget.entityType);

  bool _typeEnabled(NotificationSettings s) => switch (widget.entityType) {
        'task' => s.tasks,
        'habit' => s.habits,
        'goal' => s.goals,
        'routine' => s.routines,
        _ => true,
      };

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l = context.l10n;
    final repo = ref.read(reminderRepositoryProvider);
    final svc = LocalNotificationsService.instance;
    final settings =
        await ref.read(notificationSettingsRepoProvider).getMine();

    // First clear any existing reminder for this entity (idempotent).
    for (final r in _existing) {
      await repo.deactivate(r.id);
    }
    await svc.cancelReminder(_notifId);

    final body = <String, dynamic>{
      'entity_type': widget.entityType,
      'entity_id': widget.entityId,
    };

    final DateTime whenForQuietCheck;

    if (_mode == _Mode.once) {
      final due = widget.dueAt ?? DateTime.now();
      final remindAt = due.subtract(Duration(minutes: _leadMinutes));
      whenForQuietCheck = remindAt;
      body['remind_at'] = remindAt.toIso8601String();
      body['lead_minutes'] = _leadMinutes;
    } else {
      final hh = _timeOfDay.hour.toString().padLeft(2, '0');
      final mm = _timeOfDay.minute.toString().padLeft(2, '0');
      body['recurrence'] = reminderRecurrenceToWire(_recurrence);
      body['time_of_day'] = '$hh:$mm:00';
      if (_recurrence == ReminderRecurrence.weekly) {
        body['recurrence_days'] = [_weekdayCode(_weekday)];
      }
      final now = DateTime.now();
      whenForQuietCheck =
          DateTime(now.year, now.month, now.day, _timeOfDay.hour, _timeOfDay.minute);
    }

    try {
      await repo.create(body);
    } catch (e) {
      debugPrint('reminder create failed: $e');
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
      }
      return;
    }

    // Decide whether to actually schedule the OS notification.
    final muted = !_typeEnabled(settings);
    final quiet = settings.quietHours &&
        svc.isQuietHour(
          whenForQuietCheck,
          settings.quietStart,
          settings.quietEnd,
        );

    if (!muted && !quiet) {
      await _schedule(svc);
    }
    debugPrint(
      '[reminder] type=${widget.entityType} mode=$_mode notifId=$_notifId '
      'muted=$muted quiet=$quiet scheduled=${!muted && !quiet}',
    );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(quiet ? l.reminderQuietHoursWarning : l.reminderSaved)),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _schedule(LocalNotificationsService svc) async {
    final title = widget.entityTitle;
    final body = context.l10n.reminderBody;
    if (_mode == _Mode.once) {
      final at = widget.dueAt!.subtract(Duration(minutes: _leadMinutes));
      switch (widget.entityType) {
        case 'habit':
          await svc.scheduleHabitReminder(
              id: _notifId, title: title, body: body, at: at,);
        case 'goal':
          await svc.scheduleGoalReminder(
              id: _notifId, title: title, body: body, at: at,);
        default:
          await svc.scheduleTaskReminder(
              id: _notifId, title: title, body: body, at: at,);
      }
    } else {
      await svc.scheduleRepeating(
        id: _notifId,
        title: title,
        body: body,
        channelId: LocalNotificationsService.channelForEntity(widget.entityType),
        recurrence: reminderRecurrenceToWire(_recurrence) ?? 'daily',
        timeOfDay: _timeOfDay,
        weekday: _weekday,
      );
    }
  }

  Future<void> _delete() async {
    if (_saving) return;
    setState(() => _saving = true);
    final l = context.l10n;
    final repo = ref.read(reminderRepositoryProvider);
    for (final r in _existing) {
      await repo.deactivate(r.id);
    }
    await LocalNotificationsService.instance.cancelReminder(_notifId);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.reminderDeleted)));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: _loading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.reminderSheetTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Mode toggle (only meaningful when a due date exists).
                if (_hasDue) ...[
                  SegmentedButton<_Mode>(
                    segments: [
                      ButtonSegment(
                        value: _Mode.once,
                        label: Text(l.reminderModeOnce),
                      ),
                      ButtonSegment(
                        value: _Mode.repeating,
                        label: Text(l.reminderModeRepeating),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) =>
                        setState(() => _mode = s.first),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_mode == _Mode.once)
                  _buildOnce(l)
                else
                  _buildRepeating(l),

                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.commonSave),
                ),
                if (_existing.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _saving ? null : _delete,
                    child: Text(l.commonDelete),
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
    );
  }

  Widget _buildOnce(AppLocalizations l) {
    final options = <(int, String)>[
      (0, l.reminderAtTime),
      (5, l.reminderBefore5),
      (10, l.reminderBefore10),
      (15, l.reminderBefore15),
      (30, l.reminderBefore30),
      (60, l.reminderBefore60),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.reminderLeadLabel,
            style: Theme.of(context).textTheme.bodySmall,),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options
              .map((o) => ChoiceChip(
                    label: Text(o.$2),
                    selected: _leadMinutes == o.$1,
                    onSelected: (_) => setState(() => _leadMinutes = o.$1),
                  ),)
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRepeating(AppLocalizations l) {
    final narrow = MaterialLocalizations.of(context).narrowWeekdays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time of day
        Row(
          children: [
            Text(l.reminderTimeLabel,
                style: Theme.of(context).textTheme.bodySmall,),
            const Spacer(),
            TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _timeOfDay,
                );
                if (picked != null) setState(() => _timeOfDay = picked);
              },
              child: Text(_timeOfDay.format(context)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(l.reminderRecurrenceLabel,
            style: Theme.of(context).textTheme.bodySmall,),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _recChip(l.reminderDaily, ReminderRecurrence.daily),
            _recChip(l.reminderWeekly, ReminderRecurrence.weekly),
            _recChip(l.reminderWeekdays, ReminderRecurrence.weekdays),
            _recChip(l.reminderWeekends, ReminderRecurrence.weekends),
          ],
        ),
        if (_recurrence == ReminderRecurrence.weekly) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final wd = i + 1; // 1=Mon … 7=Sun
              return ChoiceChip(
                label: Text(narrow[wd % 7]),
                selected: _weekday == wd,
                onSelected: (_) => setState(() => _weekday = wd),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _recChip(String label, ReminderRecurrence r) => ChoiceChip(
        label: Text(label),
        selected: _recurrence == r,
        onSelected: (_) => setState(() => _recurrence = r),
      );

  static String _weekdayCode(int weekday) => const {
        1: 'mon',
        2: 'tue',
        3: 'wed',
        4: 'thu',
        5: 'fri',
        6: 'sat',
        7: 'sun',
      }[weekday]!;
}
