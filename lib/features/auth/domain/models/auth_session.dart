import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthSession {
  const AuthSession();

  const factory AuthSession.unauthenticated() = Unauthenticated;

  const factory AuthSession.guest({
    required String userId,
  }) = GuestSession;

  const factory AuthSession.email({
    required String userId,
    required String email,
  }) = EmailSession;
}

class Unauthenticated extends AuthSession {
  const Unauthenticated();
}

class GuestSession extends AuthSession {
  const GuestSession({required this.userId});
  final String userId;
}

class EmailSession extends AuthSession {
  const EmailSession({required this.userId, required this.email});
  final String userId;
  final String email;
}

bool _userIsAnonymous(User user) {
  try {
    if (user.isAnonymous == true) return true;
  } catch (_) {}
  return user.email == null || user.email!.isEmpty;
}

AuthSession authSessionFromSupabase(Session? session) {
  if (session == null) return const AuthSession.unauthenticated();
  final user = session.user;
  if (_userIsAnonymous(user)) {
    return AuthSession.guest(userId: user.id);
  }
  return AuthSession.email(
    userId: user.id,
    email: user.email ?? '',
  );
}
