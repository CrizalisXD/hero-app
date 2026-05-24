import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../auth/application/auth_notifier.dart';

class OnboardingStubScreen extends ConsumerWidget {
  const OnboardingStubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.onboardingStubTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.onboardingStubBody),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(authActionsProvider.notifier).signOut(),
              child: Text(l.signOut),
            ),
          ],
        ),
      ),
    );
  }
}
