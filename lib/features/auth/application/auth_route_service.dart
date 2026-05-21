import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/data/profiles_repository_stub.dart';

class AuthRouteService {
  AuthRouteService(this._ref);
  final Ref _ref;

  Future<String> routeAfterAuth() async {
    final profile =
        await _ref.read(profilesRepositoryStubProvider).getMyProfile();
    return profile.onboardingDone ? '/home' : '/onboarding/life-change';
  }
}

final authRouteServiceProvider = Provider<AuthRouteService>((ref) {
  return AuthRouteService(ref);
});
