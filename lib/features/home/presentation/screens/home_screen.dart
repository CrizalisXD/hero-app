import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../challenges/presentation/widgets/active_challenges_block.dart';
import '../../application/home_notifier.dart';
import '../widgets/active_goal_panel.dart';
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
        // Standard AppBar (no transparent overlay) so content never
        // peeks under the iOS status bar. The "Добрый вечер, Hero"
        // header lives inside ListView and stays below this bar.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 44,
          actions: [
            IconButton(
              icon: const Icon(Icons.sports_score_outlined),
              tooltip: context.l10n.navChallenges,
              onPressed: () => context.push('/challenges'),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: context.l10n.settingsTitle,
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              // Compact side-by-side hero card: avatar on the left,
              // greeting + level + XP/energy on the right.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HeroAvatarPanel(
                    avatar: data.avatar,
                    level: data.character.level,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: HeroProgressHeader(
                      displayName: data.displayName,
                      character: data.character,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),
              const ActiveChallengesBlock(),
            ],
          ),
        ),
      ),
    );
  }
}
