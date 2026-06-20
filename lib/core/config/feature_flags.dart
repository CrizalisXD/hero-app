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
  // Unity 3D avatar is now the default hero renderer (the iOS boot crash is
  // fixed). Pass --dart-define=HERO_UNITY_AVATAR_ENABLED=false to fall back to
  // the 2D placeholder (e.g. on a build without the Unity export).
  static const bool unityAvatarEnabled = bool.fromEnvironment(
    'HERO_UNITY_AVATAR_ENABLED',
    defaultValue: true,
  );
  static const bool avatarPhotoAiEnabled = bool.fromEnvironment(
    'HERO_AVATAR_PHOTO_AI_ENABLED',
    defaultValue: false,
  );
}
