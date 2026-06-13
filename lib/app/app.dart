import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/locale_notifier.dart';
import '../features/integrations/calendar/application/calendar_sync_agent.dart';
import '../features/siri/application/siri_command_handler.dart';
import '../features/tasks/application/tasks_notifier.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HeroApp extends ConsumerStatefulWidget {
  const HeroApp({super.key});

  @override
  ConsumerState<HeroApp> createState() => _HeroAppState();
}

class _HeroAppState extends ConsumerState<HeroApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // First-pass attempt: handle anything that's already pending from a
    // Siri-triggered cold start (UserDefaults still holds the payload).
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeHandleSiri());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeHandleSiri();
      _maybeReconcileCalendar();
    }
  }

  Future<void> _maybeHandleSiri() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !mounted) return;
    await ref.read(siriCommandHandlerProvider).handlePendingIfAny(context);
  }

  /// Best-effort 2-way calendar sync. The agent gates itself on consent
  /// + toggle + permissions, so calling it unconditionally is safe.
  Future<void> _maybeReconcileCalendar() async {
    try {
      await ref.read(calendarSyncAgentProvider).reconcile();
      // After a sync pass, refresh the tasks notifiers so newly-imported
      // or removed rows show up in the UI without the user pulling-to-
      // refresh manually.
      ref.invalidate(tasksNotifierProvider);
      ref.invalidate(todayTasksNotifierProvider);
    } catch (_) {
      // Agent already swallows errors; this is a defensive net.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final localeAsync = ref.watch(localeNotifierProvider);

    return MaterialApp.router(
      title: 'Hero',
      theme: AppTheme.dark(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      // Null while loading → MaterialApp uses system locale (OK for splash).
      locale: localeAsync.valueOrNull,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
