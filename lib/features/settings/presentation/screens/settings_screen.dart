import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        children: [
          _row(
            context,
            icon: Icons.person_outline,
            label: l.settingsSectionAccount,
            to: '/settings/account',
          ),
          _row(
            context,
            icon: Icons.translate,
            label: l.settingsSectionLanguage,
            to: '/settings/language',
          ),
          _row(
            context,
            icon: Icons.notifications_outlined,
            label: l.settingsSectionNotifications,
            to: '/settings/notifications',
          ),
          _row(
            context,
            icon: Icons.lock_outline,
            label: l.settingsSectionPrivacy,
            to: '/settings/privacy',
          ),
          _row(
            context,
            icon: Icons.favorite_outline,
            label: l.healthScreenTitle,
            to: '/settings/integrations/health',
          ),
          _row(
            context,
            icon: Icons.event_outlined,
            label: l.calendarScreenTitle,
            to: '/settings/integrations/calendar',
          ),
          _row(
            context,
            icon: Icons.psychology_outlined,
            label: l.settingsSectionAiMemory,
            to: '/settings/ai-memory',
          ),
          _row(
            context,
            icon: Icons.download_outlined,
            label: l.settingsSectionDataExport,
            to: '/settings/data',
          ),
          _row(
            context,
            icon: Icons.emoji_events_outlined,
            label: l.rewardsTitle,
            to: '/rewards',
          ),
          _row(
            context,
            icon: Icons.info_outline,
            label: l.settingsSectionAbout,
            to: '/settings/about',
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext c, {
    required IconData icon,
    required String label,
    required String to,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => c.push(to),
    );
  }
}
