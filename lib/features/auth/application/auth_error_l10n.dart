import 'package:flutter/widgets.dart';
import '../../../core/l10n/l10n.dart';
import 'failure_mappers.dart';

extension AuthFailureL10n on AuthFailureKind {
  String localized(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      AuthFailureKind.invalidCredentials => l.authErrorInvalidCredentials,
      AuthFailureKind.emailNotConfirmed => l.authErrorEmailNotConfirmed,
      AuthFailureKind.weakPassword => l.authErrorWeakPassword,
      AuthFailureKind.invalidEmail => l.authErrorInvalidEmail,
      AuthFailureKind.rateLimited => l.authErrorRateLimited,
      AuthFailureKind.guestDisabled => l.authErrorGuestDisabled,
      AuthFailureKind.guestSignOutNeedsConfirmation =>
        l.guestUpgradeSignOutWarningBody,
      AuthFailureKind.generic => l.authErrorGeneric,
    };
  }
}
