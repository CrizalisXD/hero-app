import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_notes_repository.dart';
import '../domain/models/note.dart';

part 'notes_notifier.g.dart';

/// Loads every non-deleted note of the current user, newest first.
/// Filtering by [NoteVisibility] for the UI tabs happens client-side
/// to keep the provider graph simple.
///
/// Method names are prefixed `*Note` to avoid collision with
/// AsyncNotifier's built-in `update` / `state` members.
@Riverpod(keepAlive: true)
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<List<Note>> build() async {
    final repo = ref.watch(notesRepositoryProvider);
    return repo.listNotes();
  }

  Future<Note> createNote(NoteInput input) async {
    final repo = ref.read(notesRepositoryProvider);
    final note = await repo.createNote(input);
    final current = state.valueOrNull ?? const <Note>[];
    state = AsyncData([note, ...current]);
    return note;
  }

  Future<Note> updateNote(String noteId, NoteInput input) async {
    final repo = ref.read(notesRepositoryProvider);
    final note = await repo.updateNote(noteId, input);
    final current = state.valueOrNull ?? const <Note>[];
    state = AsyncData(
      current.map((n) => n.id == noteId ? note : n).toList(growable: false),
    );
    return note;
  }

  Future<void> deleteNote(String noteId) async {
    final repo = ref.read(notesRepositoryProvider);
    final current = state.valueOrNull ?? const <Note>[];
    state = AsyncData(
      current.where((n) => n.id != noteId).toList(growable: false),
    );
    try {
      await repo.deleteNote(noteId);
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
