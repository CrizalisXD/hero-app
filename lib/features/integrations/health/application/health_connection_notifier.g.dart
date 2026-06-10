// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written — analyzer_plugin 0.12.0 ↔ analyzer 7.x conflict blocks
// `dart run build_runner build`. Same approach as other *.g.dart in tree.

part of 'health_connection_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$healthConnectionHash() => r'phase15-health-connection-v1';

/// See also [HealthConnection].
@ProviderFor(HealthConnection)
final healthConnectionProvider = AsyncNotifierProvider<HealthConnection,
    HealthConnectionState>.internal(
  HealthConnection.new,
  name: r'healthConnectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$healthConnectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HealthConnection = AsyncNotifier<HealthConnectionState>;
// ignore_for_file: type=lint
