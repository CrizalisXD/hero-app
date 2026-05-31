import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/feature_flags/feature_flag_keys.dart';
import '../../../../../core/feature_flags/feature_flag_providers.dart';
import '../../../../../core/l10n/l10n.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  /// Maps the current location to a NavigationBar index. Coach is always
  /// the last tab; Social is conditionally inserted before it.
  int _indexOf(String location, {required bool socialOn}) {
    if (location.startsWith('/tasks')) return 1;
    if (location.startsWith('/habits')) return 2;
    if (location.startsWith('/goals')) return 3;
    if (socialOn && location.startsWith('/social')) return 4;
    if (location.startsWith('/coach')) return socialOn ? 5 : 4;
    return 0;
  }

  void _onTap(BuildContext context, int i, {required bool socialOn}) {
    switch (i) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/tasks');
      case 2:
        context.go('/habits');
      case 3:
        context.go('/goals');
      case 4:
        if (socialOn) {
          context.go('/social');
        } else {
          context.go('/coach');
        }
      case 5:
        context.go('/coach');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final loc = GoRouterState.of(context).matchedLocation;
    final socialOn = ref
        .watch(featureFlagResolverOrFallbackProvider)
        .isEnabled(FeatureFlagKey.socialEnabled);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexOf(loc, socialOn: socialOn),
        onDestinationSelected: (i) => _onTap(context, i, socialOn: socialOn),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.task_alt_outlined),
            selectedIcon: const Icon(Icons.task_alt),
            label: l.navTasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_fire_department_outlined),
            selectedIcon: const Icon(Icons.local_fire_department),
            label: l.navHabits,
          ),
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: const Icon(Icons.flag),
            label: l.navGoals,
          ),
          if (socialOn)
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: l.navSocial,
            ),
          NavigationDestination(
            icon: const Icon(Icons.smart_toy_outlined),
            selectedIcon: const Icon(Icons.smart_toy),
            label: l.navCoach,
          ),
        ],
      ),
    );
  }
}
