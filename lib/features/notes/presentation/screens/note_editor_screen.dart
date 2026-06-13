import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../application/notes_notifier.dart';
import '../../domain/models/note.dart';
import '../../domain/models/note_visibility.dart';

/// Create or edit a note. Pass [noteId] = null for create, otherwise edit.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, this.noteId});
  final String? noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  NoteVisibility _visibility = NoteVisibility.private;
  bool _saving = false;
  bool _hydrated = false;

  bool get _isEdit => widget.noteId != null;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _hydrateFrom(Note n) {
    if (_hydrated) return;
    _hydrated = true;
    _titleCtrl.text = n.title ?? '';
    _contentCtrl.text = n.content;
    _visibility = n.visibility;
  }

  Future<void> _save() async {
    if (_saving) return;
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noteContentRequired)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final input = NoteInput(
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        content: content,
        visibility: _visibility,
      );
      final notifier = ref.read(notesNotifierProvider.notifier);
      if (_isEdit) {
        await notifier.updateNote(widget.noteId!, input);
      } else {
        await notifier.createNote(input);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.noteSaveError}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.noteDeleteConfirmTitle),
        content: Text(l.noteDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(notesNotifierProvider.notifier).deleteNote(widget.noteId!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.l10n.noteSaveError}: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final notes = ref.watch(notesNotifierProvider);

    if (_isEdit) {
      final found = notes.valueOrNull?.where((n) => n.id == widget.noteId);
      if (found != null && found.isNotEmpty) _hydrateFrom(found.first);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.noteEditTitle : l.noteCreateTitle),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: l.commonDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _confirmDelete,
            ),
          IconButton(
            tooltip: l.commonSave,
            icon: _saving
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l.noteTitleLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: l.noteContentLabel,
                    alignLabelWithHint: true,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _VisibilitySelector(
                value: _visibility,
                onChanged: (v) => setState(() => _visibility = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilitySelector extends StatelessWidget {
  const _VisibilitySelector({required this.value, required this.onChanged});
  final NoteVisibility value;
  final ValueChanged<NoteVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    Widget tile(NoteVisibility v, IconData icon, String label, String hint) {
      final selected = v == value;
      return ListTile(
        leading: Icon(icon, color: selected ? theme.colorScheme.primary : null),
        title: Text(label),
        subtitle: Text(hint),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? theme.colorScheme.primary : theme.disabledColor,
        ),
        onTap: () => onChanged(v),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          tile(
            NoteVisibility.private,
            Icons.lock_outline,
            l.noteVisibilityPrivate,
            l.noteVisibilityPrivateHint,
          ),
          tile(
            NoteVisibility.aiAllowed,
            Icons.smart_toy_outlined,
            l.noteVisibilityAiAllowed,
            l.noteVisibilityAiAllowedHint,
          ),
        ],
      ),
    );
  }
}
