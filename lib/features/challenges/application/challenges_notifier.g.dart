// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written — analyzer_plugin 0.12.0 ↔ analyzer 7.x conflict blocks
// `dart run build_runner build`. Same approach as other *.g.dart in tree.

part of 'challenges_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$systemChallengesNotifierHash() =>
    r'phase14-system-challenges-notifier-v1';

/// See also [SystemChallengesNotifier].
@ProviderFor(SystemChallengesNotifier)
final systemChallengesNotifierProvider = AsyncNotifierProvider<
    SystemChallengesNotifier, List<Challenge>>.internal(
  SystemChallengesNotifier.new,
  name: r'systemChallengesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemChallengesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SystemChallengesNotifier = AsyncNotifier<List<Challenge>>;

String _$myChallengesNotifierHash() =>
    r'phase14-my-challenges-notifier-v1';

/// See also [MyChallengesNotifier].
@ProviderFor(MyChallengesNotifier)
final myChallengesNotifierProvider = AsyncNotifierProvider<
    MyChallengesNotifier, List<ChallengeParticipant>>.internal(
  MyChallengesNotifier.new,
  name: r'myChallengesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myChallengesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MyChallengesNotifier = AsyncNotifier<List<ChallengeParticipant>>;
// ignore_for_file: type=lint
