import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/hero_button.dart';
import '../../../../settings/data/user_consents_repository.dart';
import '../../data/device_calendar_service.dart';

/// Persisted in SharedPreferences (TZ §15.9 — keeps Phase 15 lean,
/// move to user_integrations.sync_settings later if needed).
const _kCalDefaultIdKey = 'cal_default_id';
const _kCalSyncTasksKey = 'cal_sync_tasks';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _hasPerm = false;
  bool _busy = false;
  List<Calendar> _calendars = const [];
  String? _defaultId;
  bool _syncTasks = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final has = await DeviceCalendarService.instance.hasPermissions();
    final cals = has
        ? await DeviceCalendarService.instance.listCalendars()
        : const <Calendar>[];
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _hasPerm = has;
      _calendars = cals;
      _defaultId = prefs.getString(_kCalDefaultIdKey);
      _syncTasks = prefs.getBool(_kCalSyncTasksKey) ?? false;
    });
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    await ref
        .read(userConsentsRepoProvider)
        .setConsent(ConsentKeys.integrationCalendarRead, true);
    final ok = await DeviceCalendarService.instance.requestPermissions();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.calendarPermissionDenied)),
      );
    }
    await _bootstrap();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _toggleSync(bool v) async {
    if (v) {
      await ref
          .read(userConsentsRepoProvider)
          .setConsent(ConsentKeys.integrationCalendarWrite, true);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kCalSyncTasksKey, v);
    if (mounted) setState(() => _syncTasks = v);
  }

  Future<void> _pickCalendar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCalDefaultIdKey, id);
    if (mounted) setState(() => _defaultId = id);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.calendarScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (!_hasPerm)
            HeroButton(
              label: l.calendarConnectButton,
              isLoading: _busy,
              onPressed: _busy ? null : _connect,
            )
          else ...[
            Text(
              l.calendarPickPrimary,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            for (final c in _calendars)
              _CalendarTile(
                calendar: c,
                selected: _defaultId == c.id,
                onTap: c.id == null ? null : () => _pickCalendar(c.id!),
              ),
            const Divider(),
            SwitchListTile.adaptive(
              title: Text(l.calendarSyncTasksToggle),
              value: _syncTasks,
              onChanged: _toggleSync,
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarTile extends StatelessWidget {
  const _CalendarTile({
    required this.calendar,
    required this.selected,
    required this.onTap,
  });

  final Calendar calendar;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(calendar.name ?? '—'),
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      onTap: onTap,
    );
  }
}
