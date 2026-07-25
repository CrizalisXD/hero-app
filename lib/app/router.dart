import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/feature_flags/feature_flag_keys.dart';
import '../core/feature_flags/feature_flag_providers.dart';
import '../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../features/auth/application/auth_notifier.dart';
import '../features/auth/domain/models/auth_session.dart';
import '../features/auth/presentation/email_confirmation_screen.dart';
import '../features/auth/presentation/guest_upgrade_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/auth/presentation/welcome_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/goals/presentation/screens/goal_archetype_screen.dart';
import '../features/goals/presentation/screens/goal_create_screen.dart';
import '../features/goals/presentation/screens/goal_detail_screen.dart';
import '../features/goals/presentation/screens/goal_plan_review_screen.dart';
import '../features/goals/presentation/screens/goals_screen.dart';
import '../features/habits/presentation/screens/habits_screen.dart'
    as habits_feature;
import '../features/home/presentation/screens/home_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/onboarding/presentation/insight_screen.dart';
import '../features/challenges/presentation/screens/challenge_detail_screen.dart';
import '../features/challenges/presentation/screens/challenges_list_screen.dart';
import '../features/challenges/presentation/screens/create_challenge_screen.dart';
import '../features/integrations/calendar/presentation/screens/calendar_screen.dart';
import '../features/integrations/health/presentation/screens/health_screen.dart';
import '../features/notes/presentation/screens/note_editor_screen.dart';
import '../features/notes/presentation/screens/notes_screen.dart';
import '../features/siri/presentation/screens/siri_settings_screen.dart';
import '../features/rewards/presentation/screens/rewards_screen.dart';
import '../features/routines/presentation/screens/routines_screen.dart';
import '../features/social/presentation/screens/friend_search_screen.dart';
import '../features/social/presentation/screens/public_profile_screen.dart';
import '../features/social/presentation/screens/social_screen.dart';
import '../features/settings/presentation/screens/about_screen.dart';
import '../features/settings/presentation/screens/account_settings_screen.dart';
import '../features/settings/presentation/screens/ai_memory_settings_screen.dart';
import '../features/settings/presentation/screens/data_settings_screen.dart';
import '../features/settings/presentation/screens/language_settings_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/onboarding/presentation/energy_level_screen.dart';
import '../features/onboarding/presentation/failure_reason_screen.dart';
import '../features/onboarding/presentation/first_mission_screen.dart';
import '../features/onboarding/presentation/habits_screen.dart'
    as onboarding_habits;
import '../features/onboarding/presentation/life_change_screen.dart';
import '../features/onboarding/presentation/main_obstacle_screen.dart';
import '../features/onboarding/presentation/name_screen.dart';
import '../features/onboarding/presentation/notifications_screen.dart';
import '../features/onboarding/presentation/preferred_time_screen.dart';
import '../features/onboarding/presentation/support_style_screen.dart';
import '../features/onboarding/presentation/time_commitment_screen.dart';
import '../features/tasks/presentation/screens/tasks_screen.dart';
import '../features/wishlist/presentation/screens/dreams_screen.dart';
import '../features/wishlist/presentation/screens/dream_detail_screen.dart';
import '../features/wishlist/presentation/screens/dream_search_screen.dart';

const _publicRoutes = <String>{
  '/splash',
  '/welcome',
  '/auth/sign-in',
  '/auth/sign-up',
  '/auth/email-confirm',
};

/// Роуты, закрытые фича-флагами. UI прячет входы, но deep link или
/// ручная навигация обязаны упираться сюда же — гейт в redirect.
/// Ключ — префикс локации, значение — флаг из public.feature_flags.
const _gatedRoutePrefixes = <String, String>{
  '/social': FeatureFlagKey.socialEnabled,
  '/challenges': FeatureFlagKey.challengesEnabled,
  '/rewards': FeatureFlagKey.rewardsEnabled,
  '/notes': FeatureFlagKey.notesEnabled,
  '/settings/integrations/health': FeatureFlagKey.healthIntegrationEnabled,
  '/settings/integrations/calendar': FeatureFlagKey.calendarIntegrationEnabled,
  '/settings/voice': FeatureFlagKey.siriShortcutsEnabled,
};

final _shellNavigatorKey = GlobalKey<NavigatorState>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Public alias so non-router code (Siri lifecycle handler, deep-link
/// receivers, etc.) can fish out a BuildContext from the root navigator.
final rootNavigatorKey = _rootNavigatorKey;

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterRefresh(ref);

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
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

      for (final gated in _gatedRoutePrefixes.entries) {
        if (loc == gated.key || loc.startsWith('${gated.key}/')) {
          final flags = ref.read(featureFlagResolverOrFallbackProvider);
          if (!flags.isEnabled(gated.value)) return '/home';
          break;
        }
      }

      return null;
    },
    routes: [
      // ── Public / Auth ──
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
        builder: (_, s) => EmailConfirmationScreen(
          email: s.uri.queryParameters['email'] ?? '',
        ),
      ),
      // Guest → Email upgrade. Authenticated (guest) route — NOT public.
      GoRoute(
        path: '/auth/guest-upgrade',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const GuestUpgradeScreen(),
      ),

      // ── Settings (root-navigator, opens above shell) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/account',
        builder: (_, __) => const AccountSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/language',
        builder: (_, __) => const LanguageSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/notifications',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/privacy',
        builder: (_, __) => const PrivacySettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/ai-memory',
        builder: (_, __) => const AiMemorySettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/data',
        builder: (_, __) => const DataSettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/about',
        builder: (_, __) => const AboutScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/integrations/health',
        builder: (_, __) => const HealthScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/integrations/calendar',
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings/voice',
        builder: (_, __) => const SiriSettingsScreen(),
      ),

      // ── Notes (Phase 17) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes',
        builder: (_, __) => const NotesScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'new',
            builder: (_, __) => const NoteEditorScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: ':id',
            builder: (_, st) =>
                NoteEditorScreen(noteId: st.pathParameters['id']),
          ),
        ],
      ),

      // ── Rewards (Phase 12) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/rewards',
        builder: (_, __) => const RewardsScreen(),
      ),

      // ── Routines (Phase 21) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/routines',
        builder: (_, __) => const RoutinesScreen(),
      ),

      // ── Wishlist «Хочу попробовать» ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wishlist',
        builder: (_, __) => const DreamsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wishlist/search',
        builder: (_, __) => const DreamSearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/wishlist/:id',
        builder: (_, s) =>
            DreamDetailScreen(dreamId: s.pathParameters['id']!),
      ),

      // ── Social modals (Phase 13) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/social/search',
        builder: (_, __) => const FriendSearchScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/social/profile/:id',
        builder: (_, s) =>
            PublicProfileScreen(userId: s.pathParameters['id']!),
      ),

      // ── Challenges (Phase 14, root navigator) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/challenges',
        builder: (_, __) => const ChallengesListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/challenges/new',
        builder: (_, s) =>
            CreateChallengeScreen(initialTitle: s.extra as String?),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/challenges/:id',
        builder: (_, s) =>
            ChallengeDetailScreen(challengeId: s.pathParameters['id']!),
      ),

      // ── Onboarding v2 (outside shell — no bottom nav) ──
      GoRoute(
        path: '/onboarding/name',
        builder: (_, __) => const NameScreen(),
      ),
      GoRoute(
        path: '/onboarding/life-change',
        builder: (_, __) => const LifeChangeScreen(),
      ),
      GoRoute(
        path: '/onboarding/insight',
        builder: (_, __) => const InsightScreen(),
      ),
      GoRoute(
        path: '/onboarding/main-obstacle',
        builder: (_, __) => const MainObstacleScreen(),
      ),
      GoRoute(
        path: '/onboarding/failure-reason',
        builder: (_, __) => const FailureReasonScreen(),
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
        path: '/onboarding/preferred-time',
        builder: (_, __) => const PreferredTimeScreen(),
      ),
      GoRoute(
        path: '/onboarding/support-style',
        builder: (_, __) => const SupportStyleScreen(),
      ),
      GoRoute(
        path: '/onboarding/habits',
        builder: (_, __) => const onboarding_habits.HabitsScreen(),
      ),
      GoRoute(
        path: '/onboarding/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/onboarding/first-mission',
        builder: (_, __) => const FirstMissionScreen(),
      ),

      // ── Main tabs with bottom nav ──
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tasks',
            builder: (_, __) => const TasksScreen(),
          ),
          GoRoute(
            path: '/habits',
            builder: (_, __) => const habits_feature.HabitsScreen(),
          ),
          GoRoute(
            path: '/goals',
            builder: (_, __) => const GoalsScreen(),
          ),
          GoRoute(
            path: '/social',
            builder: (_, __) => const SocialScreen(),
          ),
          GoRoute(
            path: '/coach',
            builder: (_, __) => const AiChatScreen(),
          ),
        ],
      ),

      // ── Modal / secondary screens (above shell) ──
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile',
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/goals/new',
        builder: (_, __) => const GoalCreateScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/goals/archetype',
        builder: (_, __) => const GoalArchetypeScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/goals/review',
        builder: (_, __) => const GoalPlanReviewScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/goals/:id',
        builder: (_, s) =>
            GoalDetailScreen(goalId: s.pathParameters['id']!),
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
