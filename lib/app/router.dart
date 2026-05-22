import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_notifier.dart';
import '../features/auth/domain/models/auth_session.dart';
import '../features/auth/presentation/email_confirmation_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/home/presentation/home_stub_screen.dart';
import '../features/onboarding/presentation/avatar_intro_screen.dart';
import '../features/tasks/presentation/screens/tasks_screen.dart';
import '../features/onboarding/presentation/energy_level_screen.dart';
import '../features/onboarding/presentation/failure_reason_screen.dart';
import '../features/onboarding/presentation/first_mission_screen.dart';
import '../features/onboarding/presentation/habits_screen.dart';
import '../features/onboarding/presentation/life_change_screen.dart';
import '../features/onboarding/presentation/main_obstacle_screen.dart';
import '../features/onboarding/presentation/support_style_screen.dart';
import '../features/onboarding/presentation/time_commitment_screen.dart';

const _publicRoutes = <String>{
  '/splash',
  '/welcome',
  '/auth/sign-in',
  '/auth/sign-up',
  '/auth/email-confirm',
};


final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final session = ref.read(authSessionControllerProvider);
      final loc = state.matchedLocation;
      final isPublic = _publicRoutes.contains(loc);

      if (loc == '/splash') return null;

      if (session is Unauthenticated && !isPublic) {
        return '/welcome';
      }

      if (session is! Unauthenticated &&
          isPublic &&
          loc != '/auth/email-confirm') {
        return '/splash';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/auth/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/auth/email-confirm',
        builder: (ctx, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailConfirmationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeStubScreen(),
      ),
      GoRoute(
        path: '/onboarding/life-change',
        builder: (_, __) => const LifeChangeScreen(),
      ),
      GoRoute(
        path: '/onboarding/main-obstacle',
        builder: (_, __) => const MainObstacleScreen(),
      ),
      GoRoute(
        path: '/onboarding/energy-level',
        builder: (_, __) => const EnergyLevelScreen(),
      ),
      GoRoute(
        path: '/onboarding/time-commitment',
        builder: (_, __) => const TimeCommitmentScreen(),
      ),
      GoRoute(
        path: '/onboarding/failure-reason',
        builder: (_, __) => const FailureReasonScreen(),
      ),
      GoRoute(
        path: '/onboarding/support-style',
        builder: (_, __) => const SupportStyleScreen(),
      ),
      GoRoute(
        path: '/onboarding/habits',
        builder: (_, __) => const HabitsScreen(),
      ),
      GoRoute(
        path: '/onboarding/avatar-intro',
        builder: (_, __) => const AvatarIntroScreen(),
      ),
      GoRoute(
        path: '/onboarding/first-mission',
        builder: (_, __) => const FirstMissionScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (_, __) => const TasksScreen(),
      ),
    ],
  );
});

class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(this._ref) {
    _sub = _ref.listen<AuthSession>(
      authSessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref _ref;
  late final ProviderSubscription<AuthSession> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
