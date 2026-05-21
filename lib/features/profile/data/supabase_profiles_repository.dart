import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../domain/profile_snapshot.dart';
import '../domain/profiles_repository.dart';

class SupabaseProfilesRepository implements ProfilesRepository {
  SupabaseProfilesRepository(this._ref);
  final Ref _ref;

  @override
  Future<ProfileSnapshot> getMyProfile() async {
    final client = _ref.read(supabaseClientProvider);
    final row = await client
        .from('profiles')
        .select('onboarding_done')
        .single();
    return ProfileSnapshot(
      onboardingDone: (row['onboarding_done'] as bool?) ?? false,
    );
  }
}

final profilesRepositoryProvider = Provider<ProfilesRepository>((ref) {
  return SupabaseProfilesRepository(ref);
});
