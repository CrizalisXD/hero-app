import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/sign_up_result.dart';
import 'failure_mappers.dart';

part 'auth_notifier.g.dart';

/// Reactive stream of the current AuthSession.
///
/// keepAlive: true — must survive even when no widget temporarily listens
/// (e.g. between route transitions), since GoRouter's redirect reads it
/// every navigation.
@Riverpod(keepAlive: true)
class AuthSessionController extends _$AuthSessionController {
  StreamSubscription<AuthSession>? _sub;

  @override
  AuthSession build() {
    final repo = ref.watch(authRepositoryProvider);
    _sub = repo.watchSession().listen((s) {
      state = s;
    });
    ref.onDispose(() => _sub?.cancel());
    return repo.currentSession;
  }
}

/// Imperative auth actions. Throws [AuthFailureException] on failure.
@riverpod
class AuthActions extends _$AuthActions {
  @override
  Future<void> build() async {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<EmailSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final s = await _repo.signInWithEmail(email: email, password: password);
      // A bootstrap hiccup must not read as "sign-in failed" — the session
      // is already established (the router will move the user on), and the
      // splash screen re-runs ensureBootstrap anyway.
      try {
        await _repo.ensureBootstrap();
      } catch (_) {}
      state = const AsyncData(null);
      return s;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final res =
          await _repo.signUpWithEmail(email: email, password: password);
      if (res is SignUpConfirmed) {
        await _repo.ensureBootstrap();
      }
      state = const AsyncData(null);
      return res;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<GuestSession> signInAsGuest() async {
    state = const AsyncLoading();
    try {
      final s = await _repo.signInAsGuest();
      // Same as signInWithEmail: the guest session already exists, splash
      // retries ensureBootstrap — don't present a bootstrap hiccup as a
      // failed sign-in.
      try {
        await _repo.ensureBootstrap();
      } catch (_) {}
      state = const AsyncData(null);
      return s;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Upgrades the current anonymous guest user to an email/password account.
  /// CRITICAL: keeps the same auth.users.id — all game data stays attached.
  ///
  /// Returns [SignUpResult.needsEmailConfirmation] when the email change is
  /// pending a confirmation link — the UI must route to the email-confirm
  /// screen, NOT report success.
  Future<SignUpResult> upgradeGuestToEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final s = await _repo.upgradeGuestToEmail(
        email: email,
        password: password,
      );
      state = const AsyncData(null);
      return s;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Signs the user out.
  ///
  /// For [GuestSession]s, callers MUST pass [acknowledgeGuestDataLoss] = true.
  /// Without acknowledgement we throw `guestSignOutNeedsConfirmation` so the
  /// UI is forced to show a warning ("guest progress lives only on this
  /// device") before destroying the only key to the account.
  Future<void> signOut({bool acknowledgeGuestDataLoss = false}) async {
    final session = _repo.currentSession;
    if (session is GuestSession && !acknowledgeGuestDataLoss) {
      throw const AuthFailureException(
        AuthFailureKind.guestSignOutNeedsConfirmation,
      );
    }

    state = const AsyncLoading();
    try {
      await _repo.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
