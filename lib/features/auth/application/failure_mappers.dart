import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthFailureKind {
  invalidCredentials,
  emailNotConfirmed,
  weakPassword,
  invalidEmail,
  rateLimited,
  guestDisabled,
  guestSignOutNeedsConfirmation,
  generic,
}

class AuthFailureException implements Exception {
  const AuthFailureException(this.kind, {this.debugMessage});
  final AuthFailureKind kind;
  final String? debugMessage;

  @override
  String toString() =>
      'AuthFailureException($kind${debugMessage != null ? ': $debugMessage' : ''})';
}

AuthFailureException mapSupabaseAuthException(AuthException e) {
  final raw = e.message.toLowerCase();
  final code = (e.code ?? '').toLowerCase();

  if (code == 'invalid_credentials' || raw.contains('invalid login')) {
    return const AuthFailureException(AuthFailureKind.invalidCredentials);
  }
  if (code == 'email_not_confirmed' || raw.contains('email not confirmed')) {
    return const AuthFailureException(AuthFailureKind.emailNotConfirmed);
  }
  if (code == 'weak_password' || raw.contains('password should be')) {
    return const AuthFailureException(AuthFailureKind.weakPassword);
  }
  if (code == 'validation_failed' || raw.contains('invalid email')) {
    return const AuthFailureException(AuthFailureKind.invalidEmail);
  }
  if (code == 'over_request_rate_limit' || raw.contains('rate limit')) {
    return const AuthFailureException(AuthFailureKind.rateLimited);
  }
  if (code == 'anonymous_provider_disabled') {
    return const AuthFailureException(AuthFailureKind.guestDisabled);
  }
  return AuthFailureException(
    AuthFailureKind.generic,
    debugMessage: e.message,
  );
}
