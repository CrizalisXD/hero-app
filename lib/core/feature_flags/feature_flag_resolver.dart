import '../config/feature_flags.dart';
import 'feature_flag_keys.dart';
import 'remote_feature_flags.dart';

/// Combine compile-time (Dart) + runtime (DB) флаги.
///
/// Правило: фича включена, только если ОБА включены.
/// Если БД молчит про ключ (нет записи) — используется Dart default.
class FeatureFlagResolver {
  const FeatureFlagResolver(this._remote);
  final RemoteFeatureFlags _remote;

  bool isEnabled(String key) {
    final dart = _dartDefault(key);
    final remote = _remote.isEnabled(key);
    if (remote == null) return dart; // БД не определилась — Dart решает
    return dart && remote; // оба должны быть true
  }

  /// Map клиентских флагов → Dart compile-time дефолты.
  bool _dartDefault(String key) {
    switch (key) {
      case FeatureFlagKey.socialEnabled:
        return FeatureFlags.socialEnabled;
      case FeatureFlagKey.healthIntegrationEnabled:
        return FeatureFlags.healthEnabled;
      case FeatureFlagKey.siriShortcutsEnabled:
        return FeatureFlags.voiceEnabled;
      case FeatureFlagKey.unityAvatarEnabled:
        return FeatureFlags.unityAvatarEnabled;
      case FeatureFlagKey.photoAvatarGenerationEnabled:
        return FeatureFlags.avatarPhotoAiEnabled;
      // фичи без Dart-флага: Dart default = true, решает только БД
      case FeatureFlagKey.challengesEnabled:
        return true;
      case FeatureFlagKey.rewardsEnabled:
        return true;
      case FeatureFlagKey.calendarIntegrationEnabled:
        return true;
      case FeatureFlagKey.notesEnabled:
        return true;
      case FeatureFlagKey.externalIntegrationsEnabled:
        return true;
      default:
        return false;
    }
  }
}
