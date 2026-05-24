// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written to mirror `riverpod_generator` output, because the local
// `analyzer_plugin 0.12.0 ↔ analyzer 7.x` conflict currently blocks
// `dart run build_runner build`. Re-run codegen if the conflict is fixed —
// the regenerated file should be byte-equivalent (modulo the hash strings).

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authSessionControllerHash() =>
    r'phase2-auth-session-controller-v1';

/// See also [AuthSessionController].
@ProviderFor(AuthSessionController)
final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSession>.internal(
  AuthSessionController.new,
  name: r'authSessionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authSessionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthSessionController = Notifier<AuthSession>;

String _$authActionsHash() => r'phase2-auth-actions-v1';

/// See also [AuthActions].
@ProviderFor(AuthActions)
final authActionsProvider =
    AutoDisposeAsyncNotifierProvider<AuthActions, void>.internal(
  AuthActions.new,
  name: r'authActionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authActionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
