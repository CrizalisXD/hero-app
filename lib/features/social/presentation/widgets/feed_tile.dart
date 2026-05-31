import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../rewards/application/achievement_l10n.dart';
import '../../domain/models/feed_event.dart';

class FeedTile extends StatelessWidget {
  const FeedTile({super.key, required this.event});
  final FeedEvent event;

  /// Dispatch on titleKey — each known title has a specific payload shape.
  /// Unknown keys fall back to a raw display of the key itself (defensive).
  Widget _renderLine(BuildContext c) {
    final l = c.l10n;
    const style = TextStyle(fontSize: 14, color: AppColors.textPrimary);
    switch (event.titleKey) {
      case 'feedAchievementUnlocked':
        final achKey =
            event.payload['achievement_title_key'] as String? ?? '';
        final title = l10nAchievementTitle(c, achKey);
        return Text(
          l.feedAchievementUnlocked(event.displayName, title),
          style: style,
        );
      case 'feedLevelUp':
        final lvl = (event.payload['level'] as num?)?.toInt() ?? 1;
        return Text(l.feedLevelUp(event.displayName, lvl), style: style);
      default:
        return Text(event.titleKey, style: style);
    }
  }

  IconData _iconFor() {
    switch (event.titleKey) {
      case 'feedAchievementUnlocked':
        return Icons.emoji_events_outlined;
      case 'feedLevelUp':
        return Icons.star_outline;
      default:
        return Icons.bolt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.accentDim,
        child: Icon(_iconFor(), color: AppColors.accent, size: 20),
      ),
      title: _renderLine(context),
      subtitle: Text(
        '@${event.username}',
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
