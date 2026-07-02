import 'package:flutter/material.dart';

enum ReminderRecurrence { once, daily, weekly, weekdays, weekends, custom }

/// Maps the DB `recurrence` TEXT to the enum. `null`/unknown → [once]
/// (a one-shot reminder, identified by a non-null `remind_at`).
ReminderRecurrence reminderRecurrenceFromWire(String? raw) => switch (raw) {
      'daily' => ReminderRecurrence.daily,
      'weekly' => ReminderRecurrence.weekly,
      'weekdays' => ReminderRecurrence.weekdays,
      'weekends' => ReminderRecurrence.weekends,
      'custom' => ReminderRecurrence.custom,
      _ => ReminderRecurrence.once,
    };

String? reminderRecurrenceToWire(ReminderRecurrence r) => switch (r) {
      ReminderRecurrence.once => null,
      ReminderRecurrence.daily => 'daily',
      ReminderRecurrence.weekly => 'weekly',
      ReminderRecurrence.weekdays => 'weekdays',
      ReminderRecurrence.weekends => 'weekends',
      ReminderRecurrence.custom => 'custom',
    };

class EntityReminder {
  const EntityReminder({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    this.remindAt,
    this.leadMinutes,
    this.recurrence = ReminderRecurrence.once,
    this.recurrenceDays = const [],
    this.timeOfDay,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String entityType; // 'task' | 'habit' | 'goal' | 'routine'
  final String entityId;
  final DateTime? remindAt; // one-shot absolute time
  final int? leadMinutes; // N minutes before a task's due_at
  final ReminderRecurrence recurrence;
  final List<String> recurrenceDays;
  final TimeOfDay? timeOfDay;
  final bool isActive;
  final DateTime createdAt;

  bool get isRepeating => recurrence != ReminderRecurrence.once;

  factory EntityReminder.fromJson(Map<String, dynamic> j) {
    TimeOfDay? tod;
    final rawTod = j['time_of_day'] as String?;
    if (rawTod != null && rawTod.length >= 5) {
      final parts = rawTod.split(':');
      tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return EntityReminder(
      id: j['id'] as String,
      userId: j['user_id'] as String,
      entityType: j['entity_type'] as String,
      entityId: j['entity_id'] as String,
      remindAt: j['remind_at'] == null
          ? null
          : DateTime.parse(j['remind_at'] as String),
      leadMinutes: (j['lead_minutes'] as num?)?.toInt(),
      recurrence: reminderRecurrenceFromWire(j['recurrence'] as String?),
      recurrenceDays:
          (j['recurrence_days'] as List<dynamic>?)?.cast<String>() ?? const [],
      timeOfDay: tod,
      isActive: j['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}
