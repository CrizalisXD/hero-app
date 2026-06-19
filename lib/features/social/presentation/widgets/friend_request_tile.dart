import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../application/social_notifiers.dart';
import '../../data/supabase_social_repository.dart';
import '../../domain/models/friend_request.dart';

class FriendRequestTile extends ConsumerStatefulWidget {
  const FriendRequestTile({super.key, required this.request});
  final FriendRequest request;

  @override
  ConsumerState<FriendRequestTile> createState() =>
      _FriendRequestTileState();
}

class _FriendRequestTileState extends ConsumerState<FriendRequestTile> {
  bool _busy = false;

  Future<void> _accept() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final unlocked = await ref
          .read(socialRepositoryProvider)
          .acceptRequest(widget.request.requestId);
      if (!mounted) return;
      ref.invalidate(friendRequestsNotifierProvider);
      ref.invalidate(friendsNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.friendRequestAccepted)),
      );
      // social_first_friend achievement may have unlocked.
      if (unlocked.isNotEmpty && context.mounted) {
        await AchievementUnlockedSheet.showAll(context, unlocked);
        ref.invalidate(achievementsNotifierProvider);
      }
    } on SocialFriendException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.friendActionError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _decline() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(socialRepositoryProvider)
          .declineRequest(widget.request.requestId);
      if (mounted) ref.invalidate(friendRequestsNotifierProvider);
    } on SocialFriendException catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.friendActionError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.bgElevated,
        backgroundImage: r.senderAvatarPreviewUrl != null
            ? NetworkImage(r.senderAvatarPreviewUrl!)
            : null,
        child: r.senderAvatarPreviewUrl == null
            ? const Icon(Icons.person, color: AppColors.textSecondary)
            : null,
      ),
      title: Text('@${r.senderUsername}'),
      subtitle: Text(r.senderDisplayName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.success),
            onPressed: _busy ? null : _accept,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error),
            onPressed: _busy ? null : _decline,
          ),
        ],
      ),
    );
  }
}
