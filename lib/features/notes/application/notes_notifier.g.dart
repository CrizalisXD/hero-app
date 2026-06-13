// GENERATED CODE - DO NOT MODIFY BY HAND
// Hand-written — analyzer_plugin 0.12.0 ↔ analyzer 7.x conflict blocks
// `dart run build_runner build`. Same approach as other *.g.dart in tree.

part of 'notes_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesNotifierHash() => r'phase17-notes-notifier-v1';

/// See also [NotesNotifier].
@ProviderFor(NotesNotifier)
final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>.internal(
  NotesNotifier.new,
  name: r'notesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotesNotifier = AsyncNotifier<List<Note>>;
