import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/notifications/local_notifications_service.dart';
import '../../data/notification_settings_repository.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  NotificationSettings? _settings;
  bool _permission = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final perm = await LocalNotificationsService.instance.isPermissionGranted();
      final s = await ref.read(notificationSettingsRepoProvider).getMine();
      if (!mounted) return;
      setState(() {
        _permission = perm;
        _settings = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _update(NotificationSettings s) async {
    final previous = _settings;
    setState(() => _settings = s);
    try {
      await ref.read(notificationSettingsRepoProvider).update(s);
    } catch (_) {
      // Rollback on failure.
      if (mounted) setState(() => _settings = previous);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSectionNotifications)),
      body: _buildBody(l),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _settings == null) {
      return Center(child: Text(_error ?? '—'));
    }
    final s = _settings!;
    return ListView(
      children: [
        if (!_permission)
          Container(
            color: AppColors.warning.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: Text(l.notifPermissionDenied)),
                TextButton(
                  onPressed: () async {
                    final ok = await LocalNotificationsService.instance
                        .requestPermission();
                    if (mounted) setState(() => _permission = ok);
                  },
                  child: Text(l.notifPermissionEnable),
                ),
              ],
            ),
          ),
        SwitchListTile.adaptive(
          title: Text(l.notifTasks),
          value: s.tasks,
          onChanged: (v) => _update(s.copyWith(tasks: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifHabits),
          value: s.habits,
          onChanged: (v) => _update(s.copyWith(habits: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifGoals),
          value: s.goals,
          onChanged: (v) => _update(s.copyWith(goals: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifRoutines),
          value: s.routines,
          onChanged: (v) => _update(s.copyWith(routines: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifCoach),
          value: s.aiCoach,
          onChanged: (v) => _update(s.copyWith(aiCoach: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifSocial),
          value: s.social,
          onChanged: (v) => _update(s.copyWith(social: v)),
        ),
        SwitchListTile.adaptive(
          title: Text(l.notifChallenges),
          value: s.challenges,
          onChanged: (v) => _update(s.copyWith(challenges: v)),
        ),
        const Divider(),
        SwitchListTile.adaptive(
          title: Text(l.notifQuietHours),
          subtitle: Text(
            '${l.notifQuietStart} ${s.quietStart} · ${l.notifQuietEnd} ${s.quietEnd}',
          ),
          value: s.quietHours,
          onChanged: (v) => _update(s.copyWith(quietHours: v)),
        ),
      ],
    );
  }
}
