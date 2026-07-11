import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../profile/data/supabase_profiles_repository.dart';
import '../data/guest_account_local_store.dart';

/// Result of [AuthRouteService.decideAfterAuth] — carries the next path
/// plus flags the UI uses to surface deletion-related snackbars.
class RoutingDecision {
  const RoutingDecision({
    required this.path,
    this.deletionWasCancelled = false,
    this.deletionCancelFailed = false,
  });

  final String path;
  final bool deletionWasCancelled;

  /// A deletion IS scheduled and cancelling it failed. The UI must warn:
  /// proceeding silently would let the account be deleted while the user
  /// believes signing in saved it.
  final bool deletionCancelFailed;
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

    Map<String, dynamic>? row;
    try {
      row = await client
          .from('profiles')
          .select('scheduled_deletion_at, is_guest')
          .maybeSingle();
    } catch (_) {
      // No row yet / RLS denied — nothing to reconcile.
      row = null;
    }

    // Phase 11: if a deletion is pending, cancel it on this fresh sign-in.
    var deletionCancelled = false;
    var deletionCancelFailed = false;
    if (row != null && row['scheduled_deletion_at'] != null) {
      try {
        await client.rpc<dynamic>('cancel_account_deletion');
        deletionCancelled = true;
      } catch (_) {
        // MUST NOT be silent: the account is still scheduled for deletion
        // and the user needs to know the cancel did not go through.
        deletionCancelFailed = true;
      }
    }

    await _reconcileCompletedUpgrade(row);

    final profile =
        await _ref.read(profilesRepositoryProvider).getMyProfile();
    return RoutingDecision(
      path: profile.onboardingDone ? '/home' : '/onboarding/name',
      deletionWasCancelled: deletionCancelled,
      deletionCancelFailed: deletionCancelFailed,
    );
  }

  /// Finishes a guest→email upgrade that ran while email confirmation was
  /// pending: once the auth user has a confirmed email but the profile
  /// still says guest, flip the flags the upgrade couldn't safely flip at
  /// the time (see SupabaseAuthRepository.upgradeGuestToEmail).
  Future<void> _reconcileCompletedUpgrade(Map<String, dynamic>? row) async {
    if (row == null || row['is_guest'] != true) return;
    final client = _ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) return;
    if (user.emailConfirmedAt == null) return;
    try {
      await client.from('profiles').update({
        'is_guest': false,
        'auth_provider': 'email',
        'email': email,
      }).eq('id', user.id);
      await client.from('users').update({'email': email}).eq('id', user.id);
      await _ref.read(guestAccountLocalStoreProvider).clearGuest();
    } catch (_) {
      // Best-effort — retried on the next splash.
    }
  }
}

final authRouteServiceProvider = Provider<AuthRouteService>((ref) {
  return AuthRouteService(ref);
});
