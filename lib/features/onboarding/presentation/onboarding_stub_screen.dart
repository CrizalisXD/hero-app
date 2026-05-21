import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_notifier.dart';

class OnboardingStubScreen extends ConsumerWidget {
  const OnboardingStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding (stub)')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Onboarding will live here (Phase 3).'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(authActionsProvider.notifier).signOut(),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
