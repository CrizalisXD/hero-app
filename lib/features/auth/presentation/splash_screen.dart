import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../application/auth_notifier.dart';
import '../application/auth_route_service.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/models/auth_session.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _decided = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    if (_decided || !mounted) return;
    _decided = true;

    final session = ref.read(authSessionControllerProvider);
    debugPrint('[splash] session type=${session.runtimeType}');

    if (session is Unauthenticated) {
      if (!mounted) return;
      debugPrint('[splash] → /welcome (unauthenticated)');
      context.go('/welcome');
      return;
    }

    // 30s watchdog — if ensureBootstrap / routeAfterAuth never returns,
    // we'd otherwise be stuck on the splash forever.
    final watchdog = Future<String>.delayed(
      const Duration(seconds: 30),
      () {
        debugPrint('[splash] watchdog fired — forcing /welcome');
        return '/welcome';
      },
    );

    String next;
    var deletionCancelled = false;
    var deletionCancelFailed = false;
    try {
      debugPrint('[splash] calling ensureBootstrap…');
      await Future.any([
        ref.read(authRepositoryProvider).ensureBootstrap(),
        watchdog.then((_) => throw TimeoutException('bootstrap')),
      ]);
      debugPrint('[splash] ensureBootstrap done');

      debugPrint('[splash] calling decideAfterAuth…');
      final decision = await Future.any([
        ref.read(authRouteServiceProvider).decideAfterAuth(),
        watchdog.then((path) => RoutingDecision(path: path)),
      ]);
      next = decision.path;
      deletionCancelled = decision.deletionWasCancelled;
      deletionCancelFailed = decision.deletionCancelFailed;
      debugPrint('[splash] decideAfterAuth returned: $next');
    } catch (e, st) {
      debugPrint('[splash] error: $e\n$st');
      next = '/welcome';
    }

    if (!mounted) return;
    // Capture before navigating away — the splash Scaffold unmounts.
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l10n;
    debugPrint('[splash] context.go($next)');
    context.go(next);
    if (deletionCancelled) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.accountDeleteCancelled)),
      );
    } else if (deletionCancelFailed) {
      messenger.showSnackBar(
        SnackBar(content: Text(l.accountDeleteCancelFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.appName,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(context.l10n.splashTagline),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(context.l10n.splashLoading),
          ],
        ),
      ),
    );
  }
}
