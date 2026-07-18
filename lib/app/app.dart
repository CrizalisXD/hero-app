import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/locale_notifier.dart';
import '../features/auth/application/auth_notifier.dart';
import '../features/auth/domain/models/auth_session.dart';
import '../features/goals/application/goals_notifier.dart';
import '../features/habits/application/habits_notifier.dart';
import '../features/home/application/home_notifier.dart';
import '../features/integrations/calendar/application/calendar_sync_agent.dart';
import '../features/integrations/health/application/health_connection_notifier.dart';
import '../features/profile/application/profile_notifier.dart';
import '../features/rewards/application/achievements_notifier.dart';
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
      _refreshOnResume();
    }
  }

  /// Pull fresh server state when the app returns to the foreground, so the
  /// user never sees stale data after switching away (Health, external edits,
  /// time passing). Like "open app → it reconciles" in Health/Calendar apps.
  void _refreshOnResume() {
    // Silent so we don't tear down the embedded Unity avatar on every resume.
    unawaited(ref.read(homeNotifierProvider.notifier).silentRefresh());
    ref.invalidate(habitsNotifierProvider);
    ref.invalidate(goalsNotifierProvider);
    // Foreground-pull Health if connected (no constant background polling).
    final health = ref.read(healthConnectionProvider).valueOrNull;
    if (health?.connected == true) {
      ref.read(healthConnectionProvider.notifier).syncNow();
    }
  }

  /// On any auth identity change (login / logout / account switch) drop every
  /// user-scoped cache so the next screen loads the new user's data instead of
  /// the previous account's — no manual pull-to-refresh needed.
  void _invalidateUserScopedData() {
    ref.invalidate(homeNotifierProvider);
    ref.invalidate(tasksNotifierProvider);
    ref.invalidate(habitsNotifierProvider);
    ref.invalidate(goalsNotifierProvider);
    ref.invalidate(profileNotifierProvider);
    ref.invalidate(achievementsNotifierProvider);
  }

  String? _userId(AuthSession? s) => switch (s) {
        GuestSession(:final userId) => userId,
        EmailSession(:final userId) => userId,
        _ => null,
      };

  Future<void> _maybeHandleSiri() async {
    if (rootNavigatorKey.currentContext == null || !mounted) return;
    // On a Siri-triggered cold start this fires on the very first frame,
    // while SplashScreen is still deciding where to route. Handling now
    // would consume the one-shot payload and then get stomped by the
    // splash's own context.go(). Wait out the splash (its watchdog caps
    // it at 30s) before consuming.
    final router = ref.read(routerProvider);
    var waitedMs = 0;
    while (mounted &&
        waitedMs < 35000 &&
        router.routerDelegate.currentConfiguration.uri.path == '/splash') {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      waitedMs += 250;
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null || !context.mounted || !mounted) return;
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
    } catch (_) {
      // Agent already swallows errors; this is a defensive net.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final localeAsync = ref.watch(localeNotifierProvider);

    // Reset all user-scoped caches the moment the signed-in identity changes.
    ref.listen<AuthSession>(authSessionControllerProvider, (prev, next) {
      if (_userId(prev) != _userId(next)) {
        _invalidateUserScopedData();
      }
    });

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
