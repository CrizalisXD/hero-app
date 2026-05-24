/// AI coaching style chosen by the user during onboarding.
///
/// [wireValue] is the exact string sent to the server.
enum SupportStyle {
  direct,
  gentle,
  strict,
  analytical;

  String get wireValue => switch (this) {
        SupportStyle.direct => 'direct',
        SupportStyle.gentle => 'gentle',
        SupportStyle.strict => 'strict',
        SupportStyle.analytical => 'analytical',
      };
}
