import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../application/home_notifier.dart';
import '../../data/character_stats_repository.dart';
import '../../domain/home_data.dart';
import '../widgets/hero_avatar_stage.dart';
import '../widgets/home_error_state.dart';
import '../widgets/home_skeleton.dart';
import '../widgets/orbital_bubble.dart';

/// Immersive RPG home: a hero stage in the middle, quick-action bubbles
/// orbiting around it, and a swipe-up sheet with the day's detail panels.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: state.when(
        loading: () => const HomeSkeleton(),
        error: (_, __) => HomeErrorState(
          onRetry: () => ref.read(homeNotifierProvider.notifier).refresh(),
        ),
        data: (data) => _ImmersiveHome(data: data),
      ),
    );
  }
}

class _ImmersiveHome extends StatelessWidget {
  const _ImmersiveHome({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _Background()),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopHud(
                displayName: data.displayName,
                character: data.character,
              ),
              Expanded(
                child: _HeroStage(data: data),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Background ───────────────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15131F), AppColors.bg],
        ),
      ),
      child: Align(
        alignment: const Alignment(0, -0.35),
        child: Container(
          width: 420,
          height: 420,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.16),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Top HUD ──────────────────────────────────────────────────────────────

class _TopHud extends StatelessWidget {
  const _TopHud({required this.displayName, required this.character});
  final String displayName;
  final CharacterStats character;

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    final l = context.l10n;
    if (h < 5) return l.homeGreetingNight(displayName);
    if (h < 12) return l.homeGreetingMorning(displayName);
    if (h < 18) return l.homeGreetingDay(displayName);
    return l.homeGreetingEvening(displayName);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lowEnergy = character.energyProgress < 0.25;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(context),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      l.homeLevel(character.level),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_events_outlined),
                tooltip: l.navChallenges,
                onPressed: () => context.push('/challenges'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l.settingsTitle,
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // XP
          Row(
            children: [
              Expanded(
                child: AnimatedFillBar(
                  progress: character.xpProgress,
                  height: 9,
                  gradient: AppColors.xpGradient,
                  radius: 8,
                  duration: const Duration(milliseconds: 700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l.homeXpProgress(character.xpCurrent, character.xpToNext),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Energy
          Row(
            children: [
              const Icon(Icons.bolt, size: 14, color: AppColors.warning),
              const SizedBox(width: 4),
              Expanded(
                child: AnimatedFillBar(
                  progress: character.energyProgress,
                  height: 6,
                  gradient: lowEnergy
                      ? AppColors.energyLowGradient
                      : AppColors.energyGradient,
                  glowColorOverride:
                      lowEnergy ? AppColors.error : AppColors.warning,
                  radius: 6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l.homeEnergyValue(character.energy, character.energyMax),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Hero stage: avatar + orbital bubbles ─────────────────────────────────

class _HeroStage extends StatelessWidget {
  const _HeroStage({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    final tasksCount = data.todayTasks.length;
    final habitsTotal = data.activeHabits.length;
    final habitsDone = data.activeHabits
        .where((h) => data.habitsCheckedToday.contains(h.id))
        .length;
    final habitsPending = habitsTotal - habitsDone;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Hero fills the whole stage, nudged down + scaled up a touch so it
        // reads big and grounded near the bottom of the screen.
        Positioned.fill(
          child: Transform.translate(
            offset: const Offset(0, 40),
            child: Transform.scale(
              scale: 1.18,
              child: HeroAvatarStage(
                avatar: data.avatar,
                level: data.character.level,
              ),
            ),
          ),
        ),
        // Orbital quick actions around the hero.
        Align(
          alignment: const Alignment(-0.82, -0.5),
          child: OrbitalBubble(
            icon: Icons.task_alt,
            label: l.homeBubbleTasks,
            badge: tasksCount > 0 ? '$tasksCount' : null,
            onTap: () => context.go('/tasks'),
          ),
        ),
        Align(
          alignment: const Alignment(0.82, -0.5),
          child: OrbitalBubble(
            icon: Icons.local_fire_department,
            label: l.homeBubbleHabits,
            color: AppColors.endurance,
            badge: habitsPending > 0 ? '$habitsPending' : null,
            onTap: () => context.go('/habits'),
          ),
        ),
        Align(
          alignment: const Alignment(-0.82, 0.62),
          child: OrbitalBubble(
            icon: Icons.flag,
            label: l.homeBubbleGoals,
            color: AppColors.social,
            onTap: () => context.go('/goals'),
          ),
        ),
        Align(
          alignment: const Alignment(0.82, 0.62),
          child: OrbitalBubble(
            icon: Icons.smart_toy_outlined,
            label: l.homeBubbleCoach,
            color: AppColors.creativity,
            onTap: () => context.go('/coach'),
          ),
        ),
      ],
    );
  }
}

