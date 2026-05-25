import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../application/failure_mappers.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_session.dart';
import '../domain/models/sign_up_result.dart';
import 'guest_account_local_store.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client, {required this.guestStore});
  final SupabaseClient _client;
  final GuestAccountLocalStore guestStore;

  @override
  AuthSession get currentSession =>
      authSessionFromSupabase(_client.auth.currentSession);

  @override
  Stream<AuthSession> watchSession() {
    return _client.auth.onAuthStateChange.map(
      (event) => authSessionFromSupabase(event.session),
    );
  }

  @override
  Future<EmailSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthFailureException(AuthFailureKind.generic);
      }
      return EmailSession(userId: user.id, email: user.email ?? email.trim());
    } on AuthException catch (e) {
      throw mapSupabaseAuthException(e);
    } catch (_) {
      throw const AuthFailureException(AuthFailureKind.generic);
    }
  }

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      final session = res.session;

      if (user == null) {
        throw const AuthFailureException(AuthFailureKind.generic);
      }

      if (session != null) {
        return SignUpResult.confirmed(
          userId: user.id,
          email: user.email ?? email.trim(),
        );
      }

      return SignUpResult.needsEmailConfirmation(email: email.trim());
    } on AuthException catch (e) {
      throw mapSupabaseAuthException(e);
    } catch (_) {
      throw const AuthFailureException(AuthFailureKind.generic);
    }
  }

  /// КРИТИЧНО (§13.5):
  /// 1. Если уже есть anonymous session → переиспользуем.
  /// 2. Если есть email session → signOut → signInAnonymously.
  /// 3. Если нет session → signInAnonymously.
  @override
  Future<GuestSession> signInAsGuest() async {
    final current = _client.auth.currentSession;

    if (current != null && _isAnonymous(current.user)) {
      // Already a guest — mirror to secure storage in case it was missing.
      await guestStore.saveGuest(current.user.id);
      return GuestSession(userId: current.user.id);
    }

    if (current != null && !_isAnonymous(current.user)) {
      await _client.auth.signOut();
      await guestStore.clearGuest();
    }

    try {
      final res = await _client.auth.signInAnonymously();
      final user = res.user;
      if (user == null) {
        throw const AuthFailureException(AuthFailureKind.generic);
      }
      await guestStore.saveGuest(user.id);
      return GuestSession(userId: user.id);
    } on AuthException catch (e) {
      throw mapSupabaseAuthException(e);
    } catch (_) {
      throw const AuthFailureException(AuthFailureKind.generic);
    }
  }

  bool _isAnonymous(User user) {
    try {
      if (user.isAnonymous == true) return true;
    } catch (_) {}
    return user.email == null || user.email!.isEmpty;
  }

  /// КРИТИЧНО (§2.9.4):
  /// 1. Текущая session ДОЛЖНА быть anonymous — иначе бросаем.
  /// 2. ИСПОЛЬЗУЕМ auth.updateUser({email, password}) — НЕ signUp().
  ///    signUp создал бы НОВОГО user_id и осиротил бы guest data.
  /// 3. После updateUser обновляем profiles row (RLS пропускает own row):
  ///    is_guest = false, auth_provider = 'email', email = ...
  /// 4. user_id НЕ меняется — все habits/tasks/goals/XP остаются.
  @override
  Future<EmailSession> upgradeGuestToEmail({
    required String email,
    required String password,
  }) async {
    final current = _client.auth.currentSession;

    if (current == null || !_isAnonymous(current.user)) {
      throw const AuthFailureException(
        AuthFailureKind.generic,
        debugMessage: 'upgradeGuestToEmail called without a guest session',
      );
    }

    final userId = current.user.id;
    final trimmedEmail = email.trim();

    try {
      // (1) Bind email + password to the anonymous user — same user_id.
      await _client.auth.updateUser(
        UserAttributes(email: trimmedEmail, password: password),
      );

      // (2) Make sure bootstrap rows exist (idempotent — was guest before).
      await ensureBootstrap();

      // (3) Update profile metadata. RLS policy p_profiles_own allows
      //     the user to update their own row.
      await _client.from('profiles').update({
        'is_guest': false,
        'auth_provider': 'email',
        'email': trimmedEmail,
      }).eq('id', userId);

      // (4) Mirror onto public.users.email for joins / display.
      await _client.from('users').update({
        'email': trimmedEmail,
      }).eq('id', userId);

      // (5) No longer a guest — clear local guest flags.
      await guestStore.clearGuest();

      return EmailSession(userId: userId, email: trimmedEmail);
    } on AuthException catch (e) {
      throw mapSupabaseAuthException(e);
    } on PostgrestException catch (e) {
      throw AuthFailureException(
        AuthFailureKind.generic,
        debugMessage: 'profile update after upgrade failed: ${e.message}',
      );
    } catch (_) {
      throw const AuthFailureException(AuthFailureKind.generic);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
    await guestStore.clearGuest();
  }

  @override
  Future<void> ensureBootstrap() async {
    try {
      await _client.rpc<void>('ensure_user_bootstrap');
    } on PostgrestException catch (e) {
      throw AuthFailureException(
        AuthFailureKind.generic,
        debugMessage: 'ensure_user_bootstrap failed: ${e.message}',
      );
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final store = ref.watch(guestAccountLocalStoreProvider);
  return SupabaseAuthRepository(client, guestStore: store);
});
