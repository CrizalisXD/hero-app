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
    final ok = (data['ok'] as bool?) ?? false;
    final done = (data['onboarding_done'] as bool?) ?? false;

    // After the Edge Function has persisted users.current_* fields,
    // tell the server to scale the user's starting energy from
    // current_energy_level. RPC is idempotent and only applies when
    // the bar is still at max — see migration 0021.
    if (ok && done) {
      try {
        await client.rpc<dynamic>('apply_onboarding_to_stats');
      } catch (_) {
        // Non-fatal: the user lands on Home with the default 100/100
        // bar. They'll see the personalised value on next regen tick.
      }
    }

    return OnboardingResult(ok: ok, onboardingDone: done);
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return SupabaseOnboardingRepository(ref);
});
