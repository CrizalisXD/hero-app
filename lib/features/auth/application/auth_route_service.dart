import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../profile/data/supabase_profiles_repository.dart';

/// Result of [AuthRouteService.routeAfterAuth] — carries the next path
/// plus a flag the UI uses to surface a "deletion cancelled" snackbar.
class RoutingDecision {
  const RoutingDecision({
    required this.path,
    this.deletionWasCancelled = false,
  });
  final String path;
  final bool deletionWasCancelled;
}

class AuthRouteService {
  AuthRouteService(this._ref);
  final Ref _ref;

  /// Backwards-compatible plain-path entrypoint.
  Future<String> routeAfterAuth() async =>
      (await decideAfterAuth()).path;

  /// Full decision including the deletion-cancel signal (Phase 11 §11.2).
  Future<RoutingDecision> decideAfterAuth() async {
    final client = _ref.read(supabaseClientProvider);

    // Phase 11: if a deletion is pending, cancel it on this fresh sign-in.
    var deletionCancelled = false;
    try {
      final row = await client
          .from('profiles')
          .select('scheduled_deletion_at')
          .single();
      if (row['scheduled_deletion_at'] != null) {
        await client.rpc<dynamic>('cancel_account_deletion');
        deletionCancelled = true;
      }
    } catch (_) {
      // No row yet, RLS denied, or RPC not deployed — skip silently.
    }

    final profile =
        await _ref.read(profilesRepositoryProvider).getMyProfile();
    return RoutingDecision(
      path: profile.onboardingDone ? '/home' : '/onboarding/life-change',
      deletionWasCancelled: deletionCancelled,
    );
  }
}

final authRouteServiceProvider = Provider<AuthRouteService>((ref) {
  return AuthRouteService(ref);
});
