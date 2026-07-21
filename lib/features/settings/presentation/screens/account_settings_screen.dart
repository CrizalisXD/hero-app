import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../../auth/domain/models/auth_session.dart';
import '../../../home/data/avatar_repository.dart';
import '../../../home/presentation/widgets/hero_avatar_panel.dart';
import '../../../profile/application/profile_notifier.dart';
import '../../../profile/domain/models/profile_overview.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authSessionControllerProvider);
    final email = session is EmailSession ? session.email : null;
    final isGuest = session is GuestSession;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSectionAccount)),
      body: ListView(
        children: [
          // Tappable profile summary — the account screen used to show only
          // email + sign-out; this surfaces who is signed in and opens the
          // (already-built) full profile screen.
          profileAsync.maybeWhen(
            data: (p) => _ProfileHeader(profile: p),
            orElse: () => const SizedBox.shrink(),
          ),
          if (email != null)
            ListTile(
              title: Text(l.accountEmail),
              subtitle: Text(email),
            ),
          if (isGuest)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.accountGuestNotice),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              l.accountSignOut,
              style: const TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(l.accountSignOutConfirm),
                  content: Text(l.accountSignOutConfirmBody),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l.accountSignOutCancel),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l.accountSignOutAction),
                    ),
                  ],
                ),
              );
              if (ok != true || !context.mounted) return;
              // Dialog is the guest data-loss acknowledgement.
              await ref.read(authActionsProvider.notifier).signOut(
                    acknowledgeGuestDataLoss: true,
                  );
            },
          ),
        ],
      ),
    );
  }
}

/// Compact, tappable profile summary shown at the top of the account screen.
/// Reuses the shared [HeroAvatarPanel]; tapping anywhere opens `/profile`.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ProfileOverview profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return InkWell(
      onTap: () => context.push('/profile'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            HeroAvatarPanel(
              avatar: AvatarConfig(primaryColor: profile.avatarPrimaryColor),
              level: profile.level,
              size: 56,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    profile.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.homeLevel(profile.level),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
