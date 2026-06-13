import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile_repository.dart';
import '../domain/models/profile_overview.dart';

class ProfileNotifier extends AsyncNotifier<ProfileOverview> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<ProfileOverview> build() => _repo.loadOverview();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repo.loadOverview);
  }

  Future<void> updateDisplayName(String name) async {
    await _repo.updateDisplayName(name);
    await refresh();
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, ProfileOverview>(
  ProfileNotifier.new,
);
