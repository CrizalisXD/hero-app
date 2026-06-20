import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/feature_flags/feature_flag_keys.dart';
import '../../../../../core/feature_flags/feature_flag_providers.dart';
import '../../../avatar/unity/avatar_stage_config.dart';
import '../../../avatar/unity/unity_avatar_view.dart';
import '../../data/avatar_repository.dart';

/// The central "hero stage" of the Home screen.
///
/// This is a **swappable renderer slot**: the rest of Home depends only on
/// this widget, so the avatar implementation can evolve independently —
///   • [_PlaceholderAvatar] — ships now (no extra deps);
///   • Rive 2D — drop-in later;
///   • Unity 3D — behind the `unity_avatar_enabled` feature flag, lazily
///     embedded so its weight never affects the rest of the app.
///
/// Pick is by feature flag, so enabling Unity is a config switch — no Home
/// layout changes required.
class HeroAvatarStage extends ConsumerWidget {
  const HeroAvatarStage({
    super.key,
    required this.avatar,
    required this.level,
  });

  final AvatarConfig avatar;
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unityOn = ref
        .watch(featureFlagResolverOrFallbackProvider)
        .isEnabled(FeatureFlagKey.unityAvatarEnabled);

    // Unity 3D renderer — behind the flag. Falls back to the placeholder until
    // Unity signals ready (the placeholder shows during cold start anyway).
    if (unityOn) {
      return UnityAvatarView(
        config: AvatarStageConfig(
          primaryColor: avatar.primaryColor,
          level: level,
          renderer: 'unity',
        ),
      );
    }

    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/avatar'),
      behavior: HitTestBehavior.opaque,
      child: _PlaceholderAvatar(avatar: avatar, level: level, unityOn: unityOn),
    );
  }
}

class _PlaceholderAvatar extends StatelessWidget {
  const _PlaceholderAvatar({
    required this.avatar,
    required this.level,
    required this.unityOn,
  });

  final AvatarConfig avatar;
  final int level;
  final bool unityOn;

  Color _parseColor(String hex) {
    final s = hex.replaceFirst('#', '');
    return Color(int.parse('ff$s', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(avatar.primaryColor);
    final tier = AppColors.levelTierGradient(level);

    return LayoutBuilder(
      builder: (context, c) {
        final stage = c.biggest;
        final medallion = (stage.shortestSide * 0.62).clamp(140.0, 260.0);
        return Stack(
          alignment: Alignment.center,
          children: [
            // Soft pedestal glow under the hero.
            Positioned(
              bottom: stage.height * 0.10,
              child: Container(
                width: medallion * 1.1,
                height: medallion * 0.34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Aura glow behind the medallion.
            Container(
              width: medallion * 1.25,
              height: medallion * 1.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Tier ring + body silhouette.
            SizedBox(
              width: medallion,
              height: medallion,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(colors: [...tier, tier.first]),
                      boxShadow: [
                        BoxShadow(
                          color: tier.first.withValues(alpha: 0.4),
                          blurRadius: 28,
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.bgCard,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: medallion * 0.6,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            // Tiny hint that this is the avatar / future 3D stage.
            Positioned(
              bottom: stage.height * 0.02,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unityOn ? Icons.view_in_ar : Icons.brush_outlined,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Аватар',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
