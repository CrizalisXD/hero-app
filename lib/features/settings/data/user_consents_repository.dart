import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

/// 14 consent keys per TZ §11. Names match `public.user_consents.consent_key`.
class ConsentKeys {
  ConsentKeys._();

  // AI access
  static const String aiOnboarding = 'ai_can_use_onboarding';
  static const String aiTasks = 'ai_can_use_tasks';
  static const String aiHabits = 'ai_can_use_habits';
  static const String aiGoals = 'ai_can_use_goals';
  static const String aiHealth = 'ai_can_use_health';
  static const String aiCalendar = 'ai_can_use_calendar';
  static const String aiNotes = 'ai_can_use_notes';

  // Social
  static const String socialSearchable = 'social_profile_searchable';
  static const String socialShowAchievements = 'social_show_achievements';
  static const String socialShowChallenges = 'social_show_challenges';

  // Integrations
  static const String integrationCalendarRead = 'integration_calendar_read';
  static const String integrationCalendarWrite = 'integration_calendar_write';
  static const String integrationHealthRead = 'integration_health_read';
  static const String integrationTasksSync = 'integration_tasks_external_sync';

  static const List<String> all = [
    aiOnboarding,
    aiTasks,
    aiHabits,
    aiGoals,
    aiHealth,
    aiCalendar,
    aiNotes,
    socialSearchable,
    socialShowAchievements,
    socialShowChallenges,
    integrationCalendarRead,
    integrationCalendarWrite,
    integrationHealthRead,
    integrationTasksSync,
  ];
}

class UserConsentsRepository {
  UserConsentsRepository(this._client);
  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser!.id;

  /// Returns the full 14-key map, with missing rows defaulting to false.
  Future<Map<String, bool>> getMine() async {
    final rows =
        await _client.from('user_consents').select('consent_key, granted');
    final map = <String, bool>{for (final k in ConsentKeys.all) k: false};
    for (final r in (rows as List)) {
      final m = r as Map;
      map[m['consent_key'] as String] = m['granted'] as bool? ?? false;
    }
    return map;
  }

  Future<void> setConsent(String key, bool granted) async {
    await _client.from('user_consents').upsert(
      {
        'user_id': _uid,
        'consent_key': key,
        'granted': granted,
        'source': 'settings',
      },
      onConflict: 'user_id,consent_key',
    );
  }
}

final userConsentsRepoProvider = Provider<UserConsentsRepository>(
  (ref) => UserConsentsRepository(ref.watch(supabaseClientProvider)),
);
