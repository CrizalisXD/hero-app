/// Источник истины для имён флагов. Должен совпадать с `public.feature_flags.key`.
class FeatureFlagKey {
  FeatureFlagKey._();

  static const String socialEnabled = 'social_enabled';
  static const String challengesEnabled = 'challenges_enabled';
  static const String rewardsEnabled = 'rewards_enabled';
  static const String siriShortcutsEnabled = 'siri_shortcuts_enabled';
  static const String healthIntegrationEnabled = 'health_integration_enabled';
  static const String calendarIntegrationEnabled = 'calendar_integration_enabled';
  static const String notesEnabled = 'notes_enabled';
  static const String unityAvatarEnabled = 'unity_avatar_enabled';
  static const String photoAvatarGenerationEnabled =
      'photo_avatar_generation_enabled';
  static const String externalIntegrationsEnabled =
      'external_integrations_enabled';

  /// Все известные клиенту ключи. Используется для verification / dev tools.
  static const List<String> all = [
    socialEnabled,
    challengesEnabled,
    rewardsEnabled,
    siriShortcutsEnabled,
    healthIntegrationEnabled,
    calendarIntegrationEnabled,
    notesEnabled,
    unityAvatarEnabled,
    photoAvatarGenerationEnabled,
    externalIntegrationsEnabled,
  ];
}
