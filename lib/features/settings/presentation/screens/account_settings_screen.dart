import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../auth/application/auth_notifier.dart';
import '../../../auth/domain/models/auth_session.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authSessionControllerProvider);
    final email = session is EmailSession ? session.email : null;
    final isGuest = session is GuestSession;

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSectionAccount)),
      body: ListView(
        children: [
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
