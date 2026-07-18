import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/dream_doer.dart';

/// «Кто уже сделал» — люди с их оценкой «стоило того» и советом.
/// Пусто → приглашение стать первым, а не серая заглушка.
class DreamDoersList extends StatelessWidget {
  const DreamDoersList({super.key, required this.doers});

  final List<DreamDoer> doers;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l.dreamDetailDoersTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (doers.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                l.dreamsDoersCount(doers.length),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (doers.isEmpty)
          Text(
            l.dreamDetailDoersEmpty,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          )
        else
          for (final doer in doers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DoerTile(doer: doer),
            ),
      ],
    );
  }
}

class _DoerTile extends StatelessWidget {
  const _DoerTile({required this.doer});

  final DreamDoer doer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.accent,
                backgroundImage: doer.avatarUrl != null
                    ? NetworkImage(doer.avatarUrl!)
                    : null,
                child: doer.avatarUrl == null
                    ? Text(
                        _initials(doer.displayName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  doer.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              if (doer.worthRating != null)
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: AppColors.success),
                    const SizedBox(width: 3),
                    Text(
                      '${doer.worthRating}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (doer.note != null && doer.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              doer.note!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.characters.first;
    final second = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].characters.first
        : '';
    return '$first$second'.toUpperCase();
  }
}
