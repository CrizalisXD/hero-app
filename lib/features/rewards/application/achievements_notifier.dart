import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_achievements_repository.dart';
import '../domain/models/achievement.dart';
import '../domain/models/user_achievement.dart';

part 'achievements_notifier.g.dart';

/// View-model combining the achievement catalog with per-user unlocks.
class AchievementsView {
  const AchievementsView({required this.all, required this.unlocked});
  final List<Achievement> all;
  final Map<String, UserAchievement> unlocked;

  bool isUnlocked(String id) => unlocked.containsKey(id);
}

@Riverpod(keepAlive: true)
class AchievementsNotifier extends _$AchievementsNotifier {
  @override
  Future<AchievementsView> build() async {
    final repo = ref.watch(achievementsRepositoryProvider);
    final results = await Future.wait<dynamic>([
      repo.listAll(),
      repo.listMyUnlocked(),
    ]);
    final all = results[0] as List<Achievement>;
    final unlocked = <String, UserAchievement>{
      for (final ua in results[1] as List<UserAchievement>)
        ua.achievementId: ua,
    };
    return AchievementsView(all: all, unlocked: unlocked);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(achievementsRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.listAll(),
        repo.listMyUnlocked(),
      ]);
      final all = results[0] as List<Achievement>;
      final unlocked = <String, UserAchievement>{
        for (final ua in results[1] as List<UserAchievement>)
          ua.achievementId: ua,
      };
      return AchievementsView(all: all, unlocked: unlocked);
    });
  }
}
