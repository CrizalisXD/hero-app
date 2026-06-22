import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../goals/data/supabase_goals_repository.dart';
import '../../goals/domain/models/goal.dart';
import '../../goals/domain/models/goal_progress.dart';
import '../../habits/data/supabase_habits_repository.dart';
import '../../energy/data/energy_service.dart';
import '../../tasks/data/supabase_tasks_repository.dart';
import '../data/avatar_repository.dart';
import '../data/character_stats_repository.dart';
import '../domain/home_data.dart';

class HomeNotifier extends AsyncNotifier<HomeData> {
  @override
  Future<HomeData> build() => _load();

  /// Load Home, but recover from the common "fresh/just-switched session beats
  /// ensure_user_bootstrap" race: on the first failure, run the (idempotent)
  /// bootstrap RPC and retry once before surfacing an error.
  Future<HomeData> _load() async {
    try {
      return await _fetch();
    } catch (_) {
      try {
        await ref
            .read(supabaseClientProvider)
            .rpc<dynamic>('ensure_user_bootstrap');
      } catch (_) {/* surface the original error below if this fails too */}
      return await _fetch();
    }
  }

  Future<HomeData> _fetch() async {
    final client = ref.read(supabaseClientProvider);
    final tasksRepo = ref.read(tasksRepositoryProvider);
    final habitsRepo = ref.read(habitsRepositoryProvider);
    final goalsRepo = ref.read(goalsRepositoryProvider);
    final charRepo = ref.read(characterStatsRepositoryProvider);
    final avatarRepo = ref.read(avatarRepositoryProvider);

    // Apply passive energy regen + daily login bonus before fetching
    // character_stats so the displayed bar is already up-to-date.
    // Idempotent within the hour; safe to call on every Home load.
    await ref.read(energyServiceProvider).regen();

    // Parallel fetch of independent data sources
    final results = await Future.wait<dynamic>([
      _fetchUserRow(client),       // 0: display_name
      charRepo.getMy(),            // 1: character_stats
      avatarRepo.getMy(),          // 2: avatar
      tasksRepo.getTodayTasks(),   // 3: today pending tasks
      habitsRepo.listActive(),     // 4: active habits
      habitsRepo.habitIdsCheckedToday(), // 5: checked today
      goalsRepo.fetchGoals(),      // 6: all goals
    ]);

    final displayName =
        ((results[0] as Map<String, dynamic>)['display_name'] as String?)
            ?? 'Hero';
    final character = results[1] as CharacterStats;
    final avatar = results[2] as AvatarConfig;
    final todayTasks = (results[3] as List<dynamic>)
        .cast<dynamic>()
        .take(3)
        .toList()
        .cast<dynamic>();
    final habits = (results[4] as List<dynamic>);
    final checkedToday = results[5] as Set<String>;
    final goals = (results[6] as List<dynamic>);

    final activeGoal = goals
        .whereType<Goal>()
        .where((g) => g.status == GoalStatus.active)
        .firstOrNull;

    GoalProgress? activeGoalProgress;
    if (activeGoal != null) {
      try {
        activeGoalProgress = await goalsRepo.progressOf(activeGoal.id);
      } catch (_) {
        // Progress is optional — home doesn't crash without it
      }
    }

    return HomeData(
      displayName: displayName,
      character: character,
      avatar: avatar,
      todayTasks: todayTasks.whereType<dynamic>()
          .toList()
          .cast(),
      activeHabits: habits.cast(),
      habitsCheckedToday: checkedToday,
      activeGoal: activeGoal,
      activeGoalProgress: activeGoalProgress,
    );
  }

  Future<Map<String, dynamic>> _fetchUserRow(SupabaseClient client) async {
    return client
        .from('users')
        .select('display_name, locale')
        .single();
  }

  /// Full refresh with a loading state (shows the skeleton). Use for pull-to-
  /// refresh and account switches.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Re-fetch in the background and swap the data in place — no loading
  /// state, so Home doesn't flash the skeleton (and the embedded Unity avatar
  /// isn't torn down + re-initialised). Use after in-app mutations / on resume.
  Future<void> silentRefresh() async {
    try {
      final data = await _load();
      state = AsyncData(data);
    } catch (_) {
      // Keep the current data on a transient failure.
    }
  }
}

final homeNotifierProvider =
    AsyncNotifierProvider<HomeNotifier, HomeData>(HomeNotifier.new);
