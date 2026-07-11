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
  ///
  /// Compile-time замок оставлен ТОЛЬКО там, где фича реально может быть не
  /// собрана в билд (Unity-рендерер, фото-AI аватара). Social / Health /
  /// Siri — обычные всегда-скомпилированные экраны, поэтому ими управляет
  /// только серверный флаг (БД). Раньше они требовали ещё и dart-define
  /// (HERO_SOCIAL_ENABLED и т.п.), который по умолчанию false — из-за этого
  /// сборка без define'ов «теряла» разделы. Убрано.
  bool _dartDefault(String key) {
    switch (key) {
      case FeatureFlagKey.unityAvatarEnabled:
        return FeatureFlags.unityAvatarEnabled;
      case FeatureFlagKey.photoAvatarGenerationEnabled:
        return FeatureFlags.avatarPhotoAiEnabled;
      // Всё остальное — runtime-контроль через БД (Dart default = true).
      case FeatureFlagKey.socialEnabled:
      case FeatureFlagKey.healthIntegrationEnabled:
      case FeatureFlagKey.siriShortcutsEnabled:
      case FeatureFlagKey.challengesEnabled:
      case FeatureFlagKey.rewardsEnabled:
      case FeatureFlagKey.calendarIntegrationEnabled:
      case FeatureFlagKey.notesEnabled:
      case FeatureFlagKey.externalIntegrationsEnabled:
        return true;
      default:
        return false;
    }
  }
}
