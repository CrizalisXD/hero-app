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

    if (session is Unauthenticated) {
      if (!mounted) return;
      context.go('/welcome');
      return;
    }

    try {
      await ref.read(authRepositoryProvider).ensureBootstrap();
      final next = await ref.read(authRouteServiceProvider).routeAfterAuth();
      if (!mounted) return;
      context.go(next);
    } catch (_) {
      if (!mounted) return;
      context.go('/welcome');
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
