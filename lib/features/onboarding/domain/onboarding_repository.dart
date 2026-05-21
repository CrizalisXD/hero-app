import 'onboarding_draft.dart';

class OnboardingResult {
  const OnboardingResult({
    required this.ok,
    required this.onboardingDone,
  });
  final bool ok;
  final bool onboardingDone;
}

abstract class OnboardingRepository {
  Future<OnboardingResult> bootstrap(OnboardingDraft draft);
}
