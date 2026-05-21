import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';

class ProfileSnapshot {
  const ProfileSnapshot({required this.onboardingDone});
  final bool onboardingDone;
}

class ProfilesRepositoryStub {
  ProfilesRepositoryStub(this._ref);
  final Ref _ref;

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

final profilesRepositoryStubProvider = Provider<ProfilesRepositoryStub>((ref) {
  return ProfilesRepositoryStub(ref);
});
