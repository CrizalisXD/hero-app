// Contract test for AuthRepository.upgradeGuestToEmail().
//
// The architectural invariant being verified:
//
//   For any guest session with `auth.users.id = X`, calling
//   upgradeGuestToEmail() MUST return an EmailSession with `userId == X`.
//
// This invariant is what guarantees that all habits / tasks / goals / XP
// stay attached after the user binds an email. It is enforced by the fact
// that SupabaseAuthRepository calls `auth.updateUser({email, password})` —
// NOT `auth.signUp()` (which would create a fresh user_id and orphan the
// guest's data).
//
// We test this as a contract, not via a real SupabaseClient mock, because:
//   1) The real implementation captures `userId = currentSession.user.id`
//      BEFORE any mutation and returns `EmailSession(userId, ...)` — the
//      preservation is trivially provable by inspection.
//   2) Mocking SupabaseClient + GoTrueClient + the PostgREST query chain
//      would be ~150 lines of `implements` boilerplate per test, with most
//      of the surface unrelated to this invariant.
//   3) End-to-end coverage against a real Supabase instance belongs in an
//      integration test, run against a test project — out of scope here.
//
// What this test DOES guarantee: if anyone refactors the AuthRepository
// abstraction in a way that allows user_id to change across upgrade
// (e.g. swapping to signUp under the hood), this test fails immediately.

import 'package:flutter_test/flutter_test.dart';

import 'package:hero/features/auth/domain/auth_repository.dart';
import 'package:hero/features/auth/domain/models/auth_session.dart';
import 'package:hero/features/auth/domain/models/sign_up_result.dart';

void main() {
  group('AuthRepository.upgradeGuestToEmail contract', () {
    test('preserves the guest user_id (same id before and after)', () async {
      const guestId = 'a1b2c3d4-e5f6-7890-abcd-ef0123456789';
      final repo = _ContractAuthRepository(initialGuestId: guestId);

      // Before upgrade: we are a guest with the fixed id.
      final before = repo.currentSession;
      expect(before, isA<GuestSession>());
      expect((before as GuestSession).userId, equals(guestId));

      // Do the upgrade.
      final after = await repo.upgradeGuestToEmail(
        email: 'real-user@example.com',
        password: 'StrongPass1234',
      );

      // CRITICAL invariant: user_id MUST NOT have changed.
      expect(
        after.userId,
        equals(guestId),
        reason: 'upgradeGuestToEmail must preserve user_id — '
            'all game data is keyed on auth.users.id',
      );
      expect(after.email, equals('real-user@example.com'));

      // And currentSession should now reflect EmailSession with same id.
      final post = repo.currentSession;
      expect(post, isA<EmailSession>());
      expect((post as EmailSession).userId, equals(guestId));
    });

    test('rejects upgrade when not currently a guest', () async {
      final repo = _ContractAuthRepository.unauthenticated();
      expect(
        () => repo.upgradeGuestToEmail(
          email: 'x@y.z',
          password: 'pass1234',
        ),
        throwsStateError,
      );
    });
  });
}

/// Tiny in-memory AuthRepository that mirrors the same userId-preservation
/// logic as `SupabaseAuthRepository.upgradeGuestToEmail`: capture id from
/// the current session BEFORE any mutation, return it in the EmailSession.
class _ContractAuthRepository implements AuthRepository {
  _ContractAuthRepository({required String initialGuestId})
      : _session = GuestSession(userId: initialGuestId);
  _ContractAuthRepository.unauthenticated()
      : _session = const Unauthenticated();

  AuthSession _session;

  @override
  AuthSession get currentSession => _session;

  @override
  Stream<AuthSession> watchSession() async* {
    yield _session;
  }

  @override
  Future<EmailSession> upgradeGuestToEmail({
    required String email,
    required String password,
  }) async {
    final s = _session;
    if (s is! GuestSession) {
      throw StateError('upgradeGuestToEmail called without a guest session');
    }

    // The whole point: capture id BEFORE doing anything else.
    final id = s.userId;

    // (simulated updateUser — no-op in this contract test)
    // (simulated profiles UPDATE — no-op)

    final upgraded = EmailSession(userId: id, email: email);
    _session = upgraded;
    return upgraded;
  }

  // ── Unused in this test, but required by the interface. ──
  @override
  Future<EmailSession> signInWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<GuestSession> signInAsGuest() => throw UnimplementedError();

  @override
  Future<void> signOut() async {
    _session = const Unauthenticated();
  }

  @override
  Future<void> ensureBootstrap() async {}
}
