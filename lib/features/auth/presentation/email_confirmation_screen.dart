import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n.dart';

class EmailConfirmationScreen extends ConsumerWidget {
  const EmailConfirmationScreen({super.key, required this.email});
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 64),
              const SizedBox(height: 16),
              Text(
                l.signUpEmailConfirmTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.signUpEmailConfirmBody(email),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xB3FFFFFF)),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => context.go('/auth/sign-in'),
                child: Text(l.signUpGoToSignIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
