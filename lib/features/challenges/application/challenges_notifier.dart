import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_challenges_repository.dart';
import '../domain/models/challenge.dart';
import '../domain/models/challenge_participant.dart';

part 'challenges_notifier.g.dart';

@Riverpod(keepAlive: true)
class SystemChallengesNotifier extends _$SystemChallengesNotifier {
  @override
  Future<List<Challenge>> build() =>
      ref.read(challengesRepositoryProvider).listSystem();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(challengesRepositoryProvider).listSystem(),
    );
  }
}

@Riverpod(keepAlive: true)
class MyChallengesNotifier extends _$MyChallengesNotifier {
  @override
  Future<List<ChallengeParticipant>> build() =>
      ref.read(challengesRepositoryProvider).listMine();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(challengesRepositoryProvider).listMine(),
    );
  }
}
