import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/models/friend.dart';

class FriendTile extends StatelessWidget {
  const FriendTile({super.key, required this.friend});
  final Friend friend;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.bgElevated,
        backgroundImage: friend.avatarPreviewUrl != null
            ? NetworkImage(friend.avatarPreviewUrl!)
            : null,
        child: friend.avatarPreviewUrl == null
            ? const Icon(Icons.person, color: AppColors.textSecondary)
            : null,
      ),
      title: Text('@${friend.username}'),
      subtitle: Text(friend.displayName),
      trailing: Text(
        '${friend.publicLevel}',
        style: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => context.push('/social/profile/${friend.userId}'),
    );
  }
}
