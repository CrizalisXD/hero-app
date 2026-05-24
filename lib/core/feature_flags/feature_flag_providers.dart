import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import 'feature_flag_resolver.dart';
import 'remote_feature_flags.dart';
import 'remote_feature_flags_service.dart';

final remoteFeatureFlagsServiceProvider =
    Provider<RemoteFeatureFlagsService>((ref) {
  return RemoteFeatureFlagsService(ref.watch(supabaseClientProvider));
});

/// AsyncValue: при первом обращении грузит из БД.
/// keepAlive — кэш живёт до выхода юзера.
final remoteFeatureFlagsProvider =
    FutureProvider<RemoteFeatureFlags>((ref) async {
  return ref.read(remoteFeatureFlagsServiceProvider).get();
});

/// Resolver — AsyncValue-обёртка.
/// Использовать когда UI может ждать загрузку (редко).
final featureFlagResolverProvider =
    Provider<AsyncValue<FeatureFlagResolver>>((ref) {
  return ref.watch(remoteFeatureFlagsProvider).whenData(
        (flags) => FeatureFlagResolver(flags),
      );
});

/// Sync-версия: пока загружается — resolver работает только по Dart-флагам.
/// Используй в BottomNav и любом UI, который не должен моргать.
final featureFlagResolverOrFallbackProvider =
    Provider<FeatureFlagResolver>((ref) {
  final async = ref.watch(remoteFeatureFlagsProvider);
  return FeatureFlagResolver(
    async.valueOrNull ??
        RemoteFeatureFlags(const {}, fetchedAt: DateTime.now()),
  );
});
