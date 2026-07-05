import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/hero_button.dart';
import '../application/auth_error_l10n.dart';
import '../application/auth_notifier.dart';
import '../application/failure_mappers.dart';
import '../domain/models/sign_up_result.dart';
import 'widgets/auth_text_field.dart';

/// Lets a guest (anonymous user) attach an email + password to keep
/// their progress across devices. Calls auth.updateUser() under the
/// hood — auth.users.id stays the same.
class GuestUpgradeScreen extends ConsumerStatefulWidget {
  const GuestUpgradeScreen({super.key});

  @override
  ConsumerState<GuestUpgradeScreen> createState() =>
      _GuestUpgradeScreenState();
}

class _GuestUpgradeScreenState extends ConsumerState<GuestUpgradeScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res =
          await ref.read(authActionsProvider.notifier).upgradeGuestToEmail(
                email: _email.text,
                password: _pass.text,
              );
      if (!mounted) return;
      switch (res) {
        case SignUpConfirmed():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.guestUpgradeSuccess)),
          );
          // After upgrade, route back through splash so AuthRouteService
          // re-evaluates onboarding_done with the (now email) session.
          context.go('/splash');
        case SignUpNeedsEmailConfirmation(:final email):
          // Email change is pending the confirmation link — the account
          // stays a guest until it's clicked. Route to the confirm screen
          // instead of falsely reporting success.
          context.go(
            '/auth/email-confirm?email=${Uri.encodeQueryComponent(email)}',
          );
      }
    } on AuthFailureException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.kind.localized(context));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.guestUpgradeTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.guestUpgradeSubtitle,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xB3FFFFFF)),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: l.guestUpgradeEmailLabel,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: l.guestUpgradePasswordLabel,
                  controller: _pass,
                  obscure: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  errorText: _error,
                ),
                const SizedBox(height: 24),
                HeroButton(
                  label: l.guestUpgradeButton,
                  isLoading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
