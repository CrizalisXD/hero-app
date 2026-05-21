import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/widgets/hero_button.dart';
import '../application/auth_error_l10n.dart';
import '../application/auth_notifier.dart';
import '../application/failure_mappers.dart';
import 'widgets/auth_text_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
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
      await ref.read(authActionsProvider.notifier).signInWithEmail(
            email: _email.text,
            password: _pass.text,
          );
      if (!mounted) return;
      context.go('/splash');
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
                  l.signInTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: l.signInEmailLabel,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  label: l.signInPasswordLabel,
                  controller: _pass,
                  obscure: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                  errorText: _error,
                ),
                const SizedBox(height: 24),
                HeroButton(
                  label: l.signInButton,
                  isLoading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.signInNoAccount),
                    TextButton(
                      onPressed:
                          _loading ? null : () => context.go('/auth/sign-up'),
                      child: Text(l.signInGoToSignUp),
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
