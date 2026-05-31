import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/home_notifier.dart';
import '../widgets/active_goal_panel.dart';
import '../widgets/bubble_actions_panel.dart';
import '../widgets/daily_tasks_preview.dart';
import '../widgets/hero_avatar_panel.dart';
import '../widgets/hero_progress_header.dart';
import '../widgets/home_error_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/today_focus_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

    return state.when(
      loading: () => const HomeSkeleton(),
      error: (_, __) => HomeErrorState(
        onRetry: () => ref.read(homeNotifierProvider.notifier).refresh(),
      ),
      data: (data) => Scaffold(
        // Transparent AppBar so it sits over Home content. Only purpose:
        // expose the Settings entry point per Phase 11 §11.8.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: RefreshIndicator(
        onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            HeroAvatarPanel(
              avatar: data.avatar,
              level: data.character.level,
            ),
            const SizedBox(height: 20),
            HeroProgressHeader(
              displayName: data.displayName,
              character: data.character,
            ),
            const SizedBox(height: 24),
            const BubbleActionsPanel(),
            const SizedBox(height: 20),
            TodayFocusPanel(tasks: data.todayTasks),
            const SizedBox(height: 12),
            ActiveGoalPanel(
              goal: data.activeGoal,
              progress: data.activeGoalProgress,
            ),
            const SizedBox(height: 12),
            DailyTasksPreview(
              habits: data.activeHabits,
              checkedToday: data.habitsCheckedToday,
            ),
          ],
        ),
        ),
      ),
    );
  }
}
