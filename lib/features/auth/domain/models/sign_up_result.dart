sealed class SignUpResult {
  const SignUpResult();

  const factory SignUpResult.confirmed({
    required String userId,
    required String email,
  }) = SignUpConfirmed;

  const factory SignUpResult.needsEmailConfirmation({
    required String email,
  }) = SignUpNeedsEmailConfirmation;
}

class SignUpConfirmed extends SignUpResult {
  const SignUpConfirmed({required this.userId, required this.email});
  final String userId;
  final String email;
}

class SignUpNeedsEmailConfirmation extends SignUpResult {
  const SignUpNeedsEmailConfirmation({required this.email});
  final String email;
}
