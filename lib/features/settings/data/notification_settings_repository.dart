import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class NotificationSettings {
  const NotificationSettings({
    required this.tasks,
    required this.habits,
    required this.goals,
    required this.routines,
    required this.aiCoach,
    required this.social,
    required this.challenges,
    required this.quietHours,
    required this.quietStart,
    required this.quietEnd,
  });

  final bool tasks;
  final bool habits;
  final bool goals;
  final bool routines;
  final bool aiCoach;
  final bool social;
  final bool challenges;
  final bool quietHours;

  /// Format 'HH:MM' (e.g. '22:00').
  final String quietStart;
  final String quietEnd;

  NotificationSettings copyWith({
    bool? tasks,
    bool? habits,
    bool? goals,
    bool? routines,
    bool? aiCoach,
    bool? social,
    bool? challenges,
    bool? quietHours,
    String? quietStart,
    String? quietEnd,
  }) {
    return NotificationSettings(
      tasks: tasks ?? this.tasks,
      habits: habits ?? this.habits,
      goals: goals ?? this.goals,
      routines: routines ?? this.routines,
      aiCoach: aiCoach ?? this.aiCoach,
      social: social ?? this.social,
      challenges: challenges ?? this.challenges,
      quietHours: quietHours ?? this.quietHours,
      quietStart: quietStart ?? this.quietStart,
      quietEnd: quietEnd ?? this.quietEnd,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> j) {
    String hhmm(String? raw, String fallback) =>
        (raw == null || raw.length < 5) ? fallback : raw.substring(0, 5);
    return NotificationSettings(
      tasks: j['tasks_enabled'] as bool? ?? true,
      habits: j['habits_enabled'] as bool? ?? true,
      goals: j['goals_enabled'] as bool? ?? true,
      routines: j['routines_enabled'] as bool? ?? true,
      aiCoach: j['ai_coach_enabled'] as bool? ?? true,
      social: j['social_enabled'] as bool? ?? true,
      challenges: j['challenges_enabled'] as bool? ?? true,
      quietHours: j['quiet_hours_enabled'] as bool? ?? true,
      quietStart: hhmm(j['quiet_hours_start'] as String?, '22:00'),
      quietEnd: hhmm(j['quiet_hours_end'] as String?, '08:00'),
    );
  }

  Map<String, dynamic> toUpdate() => {
        'tasks_enabled': tasks,
        'habits_enabled': habits,
        'goals_enabled': goals,
        'routines_enabled': routines,
        'ai_coach_enabled': aiCoach,
        'social_enabled': social,
        'challenges_enabled': challenges,
        'quiet_hours_enabled': quietHours,
        'quiet_hours_start': '$quietStart:00',
        'quiet_hours_end': '$quietEnd:00',
      };
}

class NotificationSettingsRepository {
  NotificationSettingsRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  Future<NotificationSettings> getMine() async {
    final row = await _client.from('notification_settings').select().single();
    return NotificationSettings.fromJson(row);
  }

  Future<NotificationSettings> update(NotificationSettings s) async {
    final row = await _client
        .from('notification_settings')
        .update(s.toUpdate())
        .eq('user_id', _uid)
        .select()
        .single();
    return NotificationSettings.fromJson(row);
  }
}

final notificationSettingsRepoProvider =
    Provider<NotificationSettingsRepository>(
  (ref) => NotificationSettingsRepository(ref.watch(supabaseClientProvider)),
);
