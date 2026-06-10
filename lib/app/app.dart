import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/locale_notifier.dart';
import '../features/siri/application/siri_command_handler.dart';
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
    }
  }

  Future<void> _maybeHandleSiri() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null || !mounted) return;
    await ref.read(siriCommandHandlerProvider).handlePendingIfAny(context);
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
