class FeatureFlags {
  FeatureFlags._();

  static const bool socialEnabled = bool.fromEnvironment(
    'HERO_SOCIAL_ENABLED',
    defaultValue: false,
  );
  static const bool healthEnabled = bool.fromEnvironment(
    'HERO_HEALTH_ENABLED',
    defaultValue: false,
  );
  static const bool voiceEnabled = bool.fromEnvironment(
    'HERO_VOICE_ENABLED',
    defaultValue: false,
  );
  static const bool stoicEnabled = bool.fromEnvironment(
    'HERO_STOIC_ENABLED',
    defaultValue: false,
  );
  static const bool unityAvatarEnabled = bool.fromEnvironment(
    'HERO_UNITY_AVATAR_ENABLED',
    defaultValue: false,
  );
  static const bool avatarPhotoAiEnabled = bool.fromEnvironment(
    'HERO_AVATAR_PHOTO_AI_ENABLED',
    defaultValue: false,
  );
}
