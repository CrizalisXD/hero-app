import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/feature_flags/feature_flag_keys.dart';
import '../../../../core/feature_flags/feature_flag_providers.dart';
import '../../../../core/l10n/l10n.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    // Gate feature rows at the source: a disabled feature must not be pushed,
    // because the router redirect would bounce it back to '/home' — and with
    // '/home' already at the base of the stack that collides page keys
    // (Navigator "duplicate GlobalKey"). Hiding the row is the clean fix; the
    // redirect stays as defense-in-depth for cold deep links.
    final flags = ref.watch(featureFlagResolverOrFallbackProvider);
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
          if (flags.isEnabled(FeatureFlagKey.healthIntegrationEnabled))
            _row(
              context,
              icon: Icons.favorite_outline,
              label: l.healthScreenTitle,
              to: '/settings/integrations/health',
            ),
          if (flags.isEnabled(FeatureFlagKey.calendarIntegrationEnabled))
            _row(
              context,
              icon: Icons.event_outlined,
              label: l.calendarScreenTitle,
              to: '/settings/integrations/calendar',
            ),
          if (flags.isEnabled(FeatureFlagKey.siriShortcutsEnabled))
            _row(
              context,
              icon: Icons.mic_none_outlined,
              label: l.siriScreenTitle,
              to: '/settings/voice',
            ),
          if (flags.isEnabled(FeatureFlagKey.notesEnabled))
            _row(
              context,
              icon: Icons.sticky_note_2_outlined,
              label: l.settingsNotesRow,
              to: '/notes',
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
          if (flags.isEnabled(FeatureFlagKey.rewardsEnabled))
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
