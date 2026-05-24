import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feature_flag_keys.dart';
import 'feature_flag_providers.dart';

/// Dev-only экран для просмотра статуса флагов.
/// Доступен только в debug-builds.
class DebugFlagsScreen extends ConsumerWidget {
  const DebugFlagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(kDebugMode, 'DebugFlagsScreen should only be used in debug builds');
    final async = ref.watch(remoteFeatureFlagsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Feature flags')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flags) {
          final resolver =
              ref.watch(featureFlagResolverOrFallbackProvider);
          return ListView(
            children: FeatureFlagKey.all.map((key) {
              final dbEntry = flags.entries[key];
              final effective = resolver.isEnabled(key);
              return ListTile(
                title: Text(key, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  'DB=${dbEntry?.enabled.toString() ?? 'unknown'}'
                  '  rollout=${dbEntry?.rolloutPercent ?? '-'}%',
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: Icon(
                  effective ? Icons.check_circle : Icons.block,
                  color: effective ? Colors.green : Colors.grey,
                  size: 20,
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Invalidate cache',
        onPressed: () {
          ref.read(remoteFeatureFlagsServiceProvider).invalidate();
          ref.invalidate(remoteFeatureFlagsProvider);
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
