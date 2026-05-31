import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/locale_notifier.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HeroApp extends ConsumerWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
