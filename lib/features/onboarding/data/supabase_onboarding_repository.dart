import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/onboarding_draft.dart';
import '../domain/onboarding_repository.dart';

class SupabaseOnboardingRepository implements OnboardingRepository {
  SupabaseOnboardingRepository(this._ref);
  final Ref _ref;

  @override
  Future<OnboardingResult> bootstrap(OnboardingDraft draft) async {
    final client = _ref.read(supabaseClientProvider);
    final res = await client.functions.invoke(
      'onboarding-bootstrap',
      body: draft.toJson(),
    );
    final data = res.data as Map<String, dynamic>;
    return OnboardingResult(
      ok: (data['ok'] as bool?) ?? false,
      onboardingDone: (data['onboarding_done'] as bool?) ?? false,
    );
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SupabaseOnboardingRepository(ref);
});
