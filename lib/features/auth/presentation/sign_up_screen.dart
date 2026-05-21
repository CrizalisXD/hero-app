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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
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
      final res = await ref.read(authActionsProvider.notifier).signUpWithEmail(
            email: _email.text,
            password: _pass.text,
          );
      if (!mounted) return;
      switch (res) {
        case SignUpConfirmed():
          context.go('/splash');
        case SignUpNeedsEmailConfirmation(:final email):
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
                  l.signUpTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: l.signUpEmailLabel,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: l.signUpPasswordLabel,
                  controller: _pass,
                  obscure: true,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                  errorText: _error,
                ),
                const SizedBox(height: 4),
                Text(
                  l.signUpPasswordHint,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0x80FFFFFF)),
                ),
                const SizedBox(height: 24),
                HeroButton(
                  label: l.signUpButton,
                  isLoading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.signUpHasAccount),
                    TextButton(
                      onPressed:
                          _loading ? null : () => context.go('/auth/sign-in'),
                      child: Text(l.signUpGoToSignIn),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
