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

  Future<void> signOut();

  Future<void> ensureBootstrap();
}
