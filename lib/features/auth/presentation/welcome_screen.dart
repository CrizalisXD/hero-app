import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/hero_button.dart';
import '../application/auth_error_l10n.dart';
import '../application/auth_notifier.dart';
import '../application/failure_mappers.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _loading = false;

  Future<void> _guest() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ref.read(authActionsProvider.notifier).signInAsGuest();
      if (!mounted) return;
      context.go('/splash');
    } on AuthFailureException catch (e) {
      if (!mounted) return;
      _snack(e.kind.localized(context));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              Text(
                l.welcomeTitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                l.welcomeSubtitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15, color: Color(0xB3FFFFFF)),
              ),
              const Spacer(),
              HeroButton(
                label: l.welcomeSignIn,
                onPressed: _loading ? null : () => context.go('/auth/sign-in'),
              ),
              const SizedBox(height: 12),
              HeroButton(
                label: l.welcomeSignUp,
                variant: HeroButtonVariant.secondary,
                onPressed: _loading ? null : () => context.go('/auth/sign-up'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: _loading ? null : _guest,
                child: Text(l.welcomeContinueGuest),
              ),
              const SizedBox(height: 8),
              Text(
                l.welcomeGuestNote,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
              ),
              if (_loading) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
