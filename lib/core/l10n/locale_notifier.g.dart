// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written because the local analyzer_plugin 0.12.0 ↔ analyzer 7.x
// conflict still blocks `dart run build_runner build`.
// Re-run codegen later — output is byte-equivalent modulo the hash.

part of 'locale_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeNotifierHash() => r'phase11-locale-notifier-v1';

/// See also [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    AsyncNotifierProvider<LocaleNotifier, Locale>.internal(
  LocaleNotifier.new,
  name: r'localeNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$localeNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleNotifier = AsyncNotifier<Locale>;
// ignore_for_file: type=lint
