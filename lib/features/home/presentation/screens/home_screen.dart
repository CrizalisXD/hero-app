import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/feature_flags/feature_flag_keys.dart';
import '../../../../../core/feature_flags/feature_flag_providers.dart';
import '../../../../../core/widgets/animated_fill_bar.dart';
import '../../application/home_notifier.dart';
import '../../data/avatar_repository.dart';
import '../../data/character_stats_repository.dart';
import '../../domain/home_data.dart';
import '../widgets/action_wheel.dart';
import '../widgets/hero_avatar_stage.dart';
import '../widgets/home_error_state.dart';
import '../widgets/home_skeleton.dart';

/// Immersive RPG home (Quest Map): a cinematic full-screen backdrop, a compact
/// HUD with the hero avatar at the top, four quest-map nodes connected by a
/// glowing dashed path on the right, and a floating "Today's focus" card.
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

/// Parses a `#RRGGBB` / `RRGGBB` hex string into a [Color].
Color _hexColor(String hex) {
  var s = hex.replaceFirst('#', '').trim();
  if (s.length == 6) s = 'ff$s';
  return Color(int.parse(s, radix: 16));
}

/// Which node should be highlighted: first section with something to do now.
String? _activeNodeId(HomeData d) {
  if (d.activeGoal != null) return 'goals';
  if (d.todayTasks.any((t) => !t.isDone)) return 'tasks';
  if (d.activeHabits.any((h) => !d.habitsCheckedToday.contains(h.id))) {
    return 'habits';
  }
  return null;
}

class _ImmersiveHome extends StatefulWidget {
  const _ImmersiveHome({required this.data});
  final HomeData data;

  @override
  State<_ImmersiveHome> createState() => _ImmersiveHomeState();
}

class _ImmersiveHomeState extends State<_ImmersiveHome> {
  @override
  Widget build(BuildContext context) {
    // Clean z-layering per design feedback:
    //   0 — cinematic background (full screen)
    //   1 — Unity hero, FULL SCREEN + transparent, so there's no rectangular
    //       "window" seam / hazy edge where it used to end
    //   2 — HUD + action wheel, always on top of Unity (the arc/labels must
    //       never be occluded by the platform view)
    // ВАЖНО: слой Unity НЕ оборачивать в Opacity/AnimatedOpacity — opacity-
    // группа заставляет движок компоновать platform view с непрозрачным
    // чёрным фоном (это и был «чёрный квадрат»).
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: _CinematicBackground()),
        Positioned.fill(
          child: HeroAvatarStage(
            avatar: widget.data.avatar,
            level: widget.data.character.level,
          ),
        ),
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CompactHud(
                  displayName: widget.data.displayName,
                  character: widget.data.character,
                  avatar: widget.data.avatar,
                ),
                const SizedBox(height: 8),
                Expanded(child: _QuestMap(data: widget.data)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Cinematic background ─────────────────────────────────────────────────

class _CinematicBackground extends StatelessWidget {
  const _CinematicBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background photo — falls back to a dark gradient if the asset is
        // missing, so the screen always renders.
        Image.asset(
          'assets/images/home_bg.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1B1830), Color(0xFF0D0D12)],
              ),
            ),
          ),
        ),
        // Top scrim — keeps the HUD readable.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: const Alignment(0, 0.35),
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Bottom scrim — under the focus card.
        Align(
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: const Alignment(0, -0.2),
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  Colors.transparent,
                ],
              ),
            ),
            child: const SizedBox(height: 220, width: double.infinity),
          ),
        ),
      ],
    );
  }
}

// ── Compact HUD ──────────────────────────────────────────────────────────

class _CompactHud extends StatelessWidget {
  const _CompactHud({
    required this.displayName,
    required this.character,
    required this.avatar,
  });

  final String displayName;
  final CharacterStats character;
  final AvatarConfig avatar;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lowEnergy = character.energyProgress < 0.25;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AvatarCircle(avatar: avatar, level: character.level),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (b) => AppColors.heroGradient.createShader(b),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    l.homeLevel(character.level),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _HudBar(
                  progress: character.xpProgress,
                  gradient: AppColors.heroGradient,
                  glowColor: AppColors.neonMagenta,
                  label: l.homeXpProgress(
                    character.xpCurrent,
                    character.xpToNext,
                  ),
                  height: 9,
                ),
                const SizedBox(height: 4),
                _HudBar(
                  progress: character.energyProgress,
                  gradient: lowEnergy
                      ? AppColors.energyLowGradient
                      : AppColors.energyGradient,
                  label: l.homeEnergyValue(
                    character.energy,
                    character.energyMax,
                  ),
                  height: 6,
                  leadingIcon: Icons.bolt,
                  leadingColor: AppColors.warning,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: l.settingsTitle,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

/// Small avatar circle in the HUD (static colour from [AvatarConfig]).
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.avatar, required this.level});
  final AvatarConfig avatar;
  final int level;

  @override
  Widget build(BuildContext context) {
    final tierColors = AppColors.levelTierGradient(level);
    return GestureDetector(
      // Tap the HUD avatar to open the (already-built) profile screen —
      // it's the app's only entry point to the user's own profile.
      onTap: () => context.push('/profile'),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: tierColors),
          boxShadow: [
            BoxShadow(
              color: tierColors.last.withValues(alpha: 0.65),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(2.5),
        child: CircleAvatar(
          backgroundColor: AppColors.bgCard,
          child: Icon(
            Icons.person,
            color: _hexColor(avatar.primaryColor),
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Row: optional icon + progress bar + label.
class _HudBar extends StatelessWidget {
  const _HudBar({
    required this.progress,
    required this.gradient,
    required this.label,
    this.height = 8,
    this.leadingIcon,
    this.leadingColor,
    this.glowColor,
  });

  final double progress;
  final LinearGradient gradient;
  final String label;
  final double height;
  final IconData? leadingIcon;
  final Color? leadingColor;
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 13, color: leadingColor),
          const SizedBox(width: 3),
        ],
        Expanded(
          child: AnimatedFillBar(
            progress: progress,
            height: height,
            gradient: gradient,
            glowColorOverride: glowColor,
            radius: height,
            duration: const Duration(milliseconds: 700),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

// ── Action wheel ───────────────────────────────────────────────────────────

class _QuestMap extends ConsumerWidget {
  const _QuestMap({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final flags = ref.watch(featureFlagResolverOrFallbackProvider);
    final habitsPending = data.activeHabits
        .where((h) => !data.habitsCheckedToday.contains(h.id))
        .length;
    final tasksPending = data.todayTasks.where((t) => !t.isDone).length;
    final active = _activeNodeId(data);

    // Core loop first (visible at start), long-tail modules further along
    // the wheel. Flag-gated modules drop out entirely when disabled — the
    // router redirect enforces the same rule for deep links.
    final items = <WheelItem>[
      WheelItem(
        icon: Icons.flag_rounded,
        label: l.navGoals,
        color: const Color(0xFFD4AF37),
        isActive: active == 'goals',
        onTap: () => context.go('/goals'),
      ),
      WheelItem(
        icon: Icons.task_alt_rounded,
        label: l.navTasks,
        color: AppColors.accent,
        isActive: active == 'tasks',
        badge: tasksPending > 0 ? '$tasksPending' : null,
        onTap: () => context.go('/tasks'),
      ),
      WheelItem(
        icon: Icons.local_fire_department_rounded,
        label: l.navHabits,
        color: AppColors.endurance,
        isActive: active == 'habits',
        badge: habitsPending > 0 ? '$habitsPending' : null,
        onTap: () => context.go('/habits'),
      ),
      WheelItem(
        icon: Icons.smart_toy_rounded,
        label: l.navCoach,
        color: AppColors.creativity,
        onTap: () => context.go('/coach'),
      ),
      if (flags.isEnabled(FeatureFlagKey.challengesEnabled))
        WheelItem(
          icon: Icons.military_tech_rounded,
          label: l.navChallenges,
          color: AppColors.warning,
          onTap: () => context.push('/challenges'),
        ),
      if (flags.isEnabled(FeatureFlagKey.rewardsEnabled))
        WheelItem(
          icon: Icons.emoji_events_rounded,
          label: l.rewardsTitle,
          color: const Color(0xFFF59E0B),
          onTap: () => context.push('/rewards'),
        ),
      if (flags.isEnabled(FeatureFlagKey.notesEnabled))
        WheelItem(
          icon: Icons.sticky_note_2_rounded,
          label: l.navNotes,
          color: AppColors.info,
          onTap: () => context.push('/notes'),
        ),
      if (flags.isEnabled(FeatureFlagKey.socialEnabled))
        WheelItem(
          icon: Icons.people_alt_rounded,
          label: l.navSocial,
          color: const Color(0xFF4FC3F7),
          onTap: () => context.push('/social'),
        ),
      WheelItem(
        icon: Icons.event_repeat_rounded,
        label: l.navRoutines,
        color: const Color(0xFF4DD0A0),
        onTap: () => context.push('/routines'),
      ),
      WheelItem(
        icon: Icons.lightbulb_outline_rounded,
        label: l.navWishlist,
        color: const Color(0xFFFF6FB5),
        onTap: () => context.push('/wishlist'),
      ),
    ];

    // Start with the core loop (Goals…Coach) in the window: the active zone
    // sits between Tasks and Habits.
    return ActionWheel(items: items, centerIndexAtStart: 1.5);
  }
}
