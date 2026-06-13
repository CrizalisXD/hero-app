import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/notes_notifier.dart';
import '../../domain/models/note.dart';
import '../../domain/models/note_visibility.dart';
import '../widgets/note_tile.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final notes = ref.watch(notesNotifierProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.notesTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l.notesPrivateTab),
              Tab(text: l.notesAiAllowedTab),
            ],
          ),
        ),
        body: notes.when(
          data: (rows) => TabBarView(
            children: [
              _NoteList(
                rows: rows.where((n) => n.visibility == NoteVisibility.private).toList(),
                emptyHint: l.notesPrivateEmpty,
              ),
              _NoteList(
                rows: rows.where((n) => n.visibility == NoteVisibility.aiAllowed).toList(),
                emptyHint: l.notesAiAllowedEmpty,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/notes/new'),
          tooltip: l.notesAddTooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _NoteList extends StatelessWidget {
  const _NoteList({required this.rows, required this.emptyHint});
  final List<Note> rows;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final n = rows[i];
        return NoteTile(
          note: n,
          onTap: () => ctx.push('/notes/${n.id}'),
        );
      },
    );
  }
}
