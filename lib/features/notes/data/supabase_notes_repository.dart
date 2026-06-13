import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/models/note.dart';
import '../domain/models/note_visibility.dart';

/// Talks to Postgres `notes` table + the two RPCs from migration 0017.
///
/// All queries rely on RLS (`p_notes_own`) for row-scoping — no manual
/// user_id filtering on reads. On writes we still pass user_id explicitly
/// because the column is NOT NULL and the Supabase SDK doesn't fill it.
class SupabaseNotesRepository {
  SupabaseNotesRepository(this._client);
  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) {
      throw StateError('notes repo called without an auth session');
    }
    return id;
  }

  Future<List<Note>> listNotes({NoteVisibility? visibility}) async {
    final raw = await _client.rpc<dynamic>(
      'list_notes',
      params: {
        if (visibility != null) 'p_visibility': visibility.wire,
        'p_limit': 200,
      },
    );
    final rows = (raw as List?) ?? const [];
    return rows
        .cast<Map<String, dynamic>>()
        .map(Note.fromJson)
        .toList(growable: false);
  }

  Future<Note> createNote(NoteInput input) async {
    final row = await _client
        .from('notes')
        .insert(input.toInsertBody(userId: _uid))
        .select()
        .single();
    return Note.fromJson(row);
  }

  Future<Note> updateNote(String noteId, NoteInput input) async {
    final row = await _client
        .from('notes')
        .update(input.toUpdateBody())
        .eq('id', noteId)
        .select()
        .single();
    return Note.fromJson(row);
  }

  /// Soft delete — flips `is_deleted = true` so the row stays for audit
  /// but is filtered out everywhere (list_notes RPC, ai-chat fetch).
  Future<void> deleteNote(String noteId) async {
    try {
      await _client.rpc<dynamic>(
        'delete_note',
        params: {'p_note_id': noteId},
      );
    } on PostgrestException catch (e) {
      debugPrint('delete_note err: ${e.code} | ${e.message}');
      rethrow;
    }
  }
}

final notesRepositoryProvider = Provider<SupabaseNotesRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseNotesRepository(client);
});
