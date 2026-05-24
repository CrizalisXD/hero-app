import 'models/auth_session.dart';
import 'models/sign_up_result.dart';

abstract class AuthRepository {
  AuthSession get currentSession;

  Stream<AuthSession> watchSession();

  Future<EmailSession> signInWithEmail({
    required String email,
    required String password,
  });

  Future<SignUpResult> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<GuestSession> signInAsGuest();

  /// Upgrades the current anonymous session to an email/password account,
  /// PRESERVING the same auth.users.id. All game progress stays attached.
  ///
  /// MUST use auth.updateUser({email, password}) — NEVER auth.signUp(),
  /// which would create a fresh user_id and orphan the guest's data.
  ///
  /// Throws [AuthFailureException] if current session is not a guest.
  Future<EmailSession> upgradeGuestToEmail({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> ensureBootstrap();
}
