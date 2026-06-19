import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/models/note.dart';
import '../../domain/models/note_visibility.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final isAi = note.visibility == NoteVisibility.aiAllowed;
    final preview = note.content.trim().split('\n').first;

    final tile = ListTile(
      onTap: onTap,
      leading: Icon(
        isAi ? Icons.smart_toy_outlined : Icons.lock_outline,
        color: isAi ? theme.colorScheme.primary : theme.disabledColor,
      ),
      title: Text(
        note.title?.trim().isNotEmpty == true
            ? note.title!
            : (preview.isEmpty ? l.noteUntitled : preview),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        isAi ? l.noteVisibilityAiAllowed : l.noteVisibilityPrivate,
        style: theme.textTheme.bodySmall,
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey('note-${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error.withValues(alpha: 0.8),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}
