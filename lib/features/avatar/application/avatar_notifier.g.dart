// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written to mirror `riverpod_generator` output, because the local
// `analyzer_plugin 0.12.0 ↔ analyzer 7.x` conflict currently blocks
// `dart run build_runner build`. Re-run codegen if the conflict is fixed —
// the regenerated file should be byte-equivalent (modulo the hash strings).

part of 'avatar_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarNotifierHash() => r'phase10-avatar-notifier-v1';

/// See also [AvatarNotifier].
@ProviderFor(AvatarNotifier)
final avatarNotifierProvider =
    AsyncNotifierProvider<AvatarNotifier, Avatar>.internal(
  AvatarNotifier.new,
  name: r'avatarNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$avatarNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AvatarNotifier = AsyncNotifier<Avatar>;
// ignore_for_file: type=lint
