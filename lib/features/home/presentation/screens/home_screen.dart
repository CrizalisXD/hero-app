import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../../app/theme/app_colors.dart';
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
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(child: _CinematicBackground()),
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            child: Stack(
              children: [
                SafeArea(
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
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // 3D Unity hero (or placeholder) behind the nodes.
                            _HeroLayer(
                              avatar: widget.data.avatar,
                              level: widget.data.character.level,
                            ),
                            _QuestMap(data: widget.data),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _FocusCard(data: widget.data),
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
                Text(
                  l.homeLevel(character.level),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                  ),
                ),
                const SizedBox(height: 6),
                _HudBar(
                  progress: character.xpProgress,
                  gradient: AppColors.xpGradient,
                  label: l.homeXpProgress(
                    character.xpCurrent,
                    character.xpToNext,
                  ),
                  height: 8,
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.mail_outline, color: Colors.white),
                tooltip: l.navSocial,
                onPressed: () => context.push('/social'),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: l.settingsTitle,
                onPressed: () => context.push('/settings'),
              ),
            ],
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
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: tierColors),
        boxShadow: [
          BoxShadow(
            color: tierColors.first.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
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
  });

  final double progress;
  final LinearGradient gradient;
  final String label;
  final double height;
  final IconData? leadingIcon;
  final Color? leadingColor;

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

// ── Hero layer (3D Unity avatar / placeholder) ─────────────────────────────

class _HeroLayer extends StatelessWidget {
  const _HeroLayer({required this.avatar, required this.level});
  final AvatarConfig avatar;
  final int level;

  @override
  Widget build(BuildContext context) {
    // Scale up anchored to the top edge so the hero grows downward (grounded
    // near the floor) instead of bleeding up over the HUD.
    return Transform.translate(
      offset: const Offset(0, 24),
      child: Transform.scale(
        scale: 1.2,
        alignment: Alignment.topCenter,
        child: HeroAvatarStage(avatar: avatar, level: level),
      ),
    );
  }
}

// ── Action wheel ───────────────────────────────────────────────────────────

class _QuestMap extends StatelessWidget {
  const _QuestMap({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final habitsPending = data.activeHabits
        .where((h) => !data.habitsCheckedToday.contains(h.id))
        .length;
    final active = _activeNodeId(data);

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
      // Placeholders — screens land in a later phase (TZ §5 tail).
      WheelItem(
        icon: Icons.repeat_rounded,
        label: l.navRoutines,
        color: AppColors.health,
        onTap: () => _comingSoon(context),
      ),
      WheelItem(
        icon: Icons.sticky_note_2_rounded,
        label: l.navNotes,
        color: AppColors.info,
        onTap: () => _comingSoon(context),
      ),
      WheelItem(
        icon: Icons.lightbulb_outline_rounded,
        label: l.navWishlist,
        color: const Color(0xFFFF6FB5),
        onTap: () => _comingSoon(context),
      ),
      WheelItem(
        icon: Icons.notifications_rounded,
        label: l.navReminders,
        color: AppColors.warning,
        onTap: () => _comingSoon(context),
      ),
    ];

    return ActionWheel(items: items);
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.comingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ── Floating "Today's focus" card ──────────────────────────────────────────

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.data});
  final HomeData data;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tasks = data.todayTasks.where((t) => !t.isDone).take(3).toList();
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset + 8 < 16 ? 16 : bottomInset + 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A24).withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.homeFocusTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tasks.isEmpty
                            ? l.homeFocusEmpty
                            : tasks.map((t) => t.title).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/tasks'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l.homeFocusAddTask,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
