class FeatureFlagEntry {
  const FeatureFlagEntry({
    required this.key,
    required this.enabled,
    required this.rolloutPercent,
    required this.payload,
  });

  final String key;
  final bool enabled;
  final int rolloutPercent;
  final Map<String, dynamic> payload;

  factory FeatureFlagEntry.fromJson(Map<String, dynamic> json) =>
      FeatureFlagEntry(
        key: json['key'] as String,
        enabled: json['enabled'] as bool? ?? false,
        rolloutPercent: (json['rollout_percent'] as num?)?.toInt() ?? 0,
        payload:
            (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}

/// Immutable snapshot — карта известных серверу флагов.
class RemoteFeatureFlags {
  const RemoteFeatureFlags(this.entries, {required this.fetchedAt});

  final Map<String, FeatureFlagEntry> entries;
  final DateTime fetchedAt;

  /// Если ключ есть в БД → его enabled. Иначе null («БД не имеет мнения»).
  bool? isEnabled(String key) => entries[key]?.enabled;
}
