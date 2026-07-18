import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/dream_comment.dart';

const _pink = Color(0xFFFF6FB5);

/// Обсуждение у канонической мечты. Реплики от тех, кто её сделал, помечены
/// оценкой «стоило того» — совет прошедшего путь весит иначе, чем мнение
/// зрителя.
class DreamComments extends StatefulWidget {
  const DreamComments({
    super.key,
    required this.comments,
    required this.onSubmit,
  });

  final List<DreamComment> comments;

  /// Возвращает true при успехе — тогда поле очищается.
  final Future<bool> Function(String body) onSubmit;

  @override
  State<DreamComments> createState() => _DreamCommentsState();
}

class _DreamCommentsState extends State<DreamComments> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final ok = await widget.onSubmit(text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.dreamDetailCommentsTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                maxLength: 2000,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l.dreamDetailCommentHint,
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: _pink),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.comments.isEmpty)
          Text(
            l.dreamDetailCommentsEmpty,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          )
        else
          for (final c in widget.comments)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CommentTile(comment: c),
            ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final DreamComment comment;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.accent,
              backgroundImage: comment.authorAvatarUrl != null
                  ? NetworkImage(comment.authorAvatarUrl!)
                  : null,
              child: comment.authorAvatarUrl == null
                  ? Text(
                      _initials(comment.authorName ?? '?'),
                      style: const TextStyle(color: Colors.white, fontSize: 9),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              comment.authorName ?? 'Hero',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
            // Метка «сделал(а) это» отличает совет прошедшего путь.
            if (comment.isFromDoer) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, size: 11, color: AppColors.success),
                    const SizedBox(width: 3),
                    Text(
                      l.dreamDetailFromDoer,
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 4),
          child: Text(
            comment.body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final t = name.trim();
    return t.isEmpty ? '?' : t.characters.first.toUpperCase();
  }
}
