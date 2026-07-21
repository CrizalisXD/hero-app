import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/hero_error_view.dart';
import '../../../../core/widgets/animated_fill_bar.dart';
import '../../../../core/widgets/hero_button.dart';
import '../../../../core/widgets/hero_card.dart';
import '../../../categories/domain/models/category_id.dart';
import '../../../home/data/avatar_repository.dart';
import '../../../home/presentation/widgets/hero_avatar_panel.dart';
import '../../../tasks/presentation/widgets/category_chip.dart';
import '../../application/profile_notifier.dart';
import '../../domain/models/profile_overview.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => HeroErrorView(onRetry: () => ref.invalidate(profileNotifierProvider)),
        data: (p) => RefreshIndicator(
          onRefresh: () =>
              ref.read(profileNotifierProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _HeaderCard(profile: p),
              const SizedBox(height: 16),
              _StatsCard(meta: p.metaStats, coins: p.metaStats.coins),
              const SizedBox(height: 16),
              _CategoriesCard(categories: p.categories),
              const SizedBox(height: 16),
              HeroButton(
                label: l.profileEditDisplayName,
                icon: Icons.edit_outlined,
                variant: HeroButtonVariant.secondary,
                onPressed: () => _editName(context, ref, p.displayName),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final l = ctx.l10n;
        return AlertDialog(
          title: Text(l.profileEditDisplayName),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            maxLength: 30,
            decoration: InputDecoration(labelText: l.profileDisplayNameLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
              child: Text(l.commonSave),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateDisplayName(result);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────
// Header card: avatar + name + level + XP + energy
// ──────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.profile});
  final ProfileOverview profile;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return HeroCard(
      child: Column(
        children: [
          Row(
            children: [
              HeroAvatarPanel(
                avatar: AvatarConfig(
                  primaryColor: profile.avatarPrimaryColor,
                ),
                level: profile.level,
                size: 88,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (profile.username != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '@${profile.username}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: '@${profile.username}'),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l.profileUsernameCopied),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  Icons.copy,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (profile.email != null && profile.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          profile.email!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      l.homeLevel(profile.level),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.profileXpTotal(profile.xpTotal),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _XpBar(current: profile.xpCurrent, toNext: profile.xpToNext),
          const SizedBox(height: 10),
          _EnergyBar(current: profile.energy, max: profile.energyMax),
        ],
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  const _XpBar({required this.current, required this.toNext});
  final int current;
  final int toNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = toNext == 0 ? 0.0 : (current / toNext).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedFillBar(
          progress: v,
          height: 10,
          gradient: AppColors.xpGradient,
          radius: 8,
          duration: const Duration(milliseconds: 700),
        ),
        const SizedBox(height: 4),
        Text(
          l.homeXpProgress(current, toNext),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _EnergyBar extends StatelessWidget {
  const _EnergyBar({required this.current, required this.max});
  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = max == 0 ? 0.0 : (current / max).clamp(0.0, 1.0);
    return Row(
      children: [
        const Icon(Icons.bolt, size: 14, color: AppColors.warning),
        const SizedBox(width: 4),
        Text(l.homeEnergy, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedFillBar(
            progress: v,
            height: 6,
            gradient: v < 0.25
                ? AppColors.energyLowGradient
                : AppColors.energyGradient,
            glowColorOverride: v < 0.25 ? AppColors.error : AppColors.warning,
            radius: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l.homeEnergyValue(current, max),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
// Meta-stats card
// ──────────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.meta, required this.coins});
  final dynamic meta; // MetaStats
  final int coins;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.profileStatsSectionTitle,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _Row(
            icon: Icons.fitness_center_outlined,
            label: l.profileStatDiscipline,
            value: '${meta.disciplineXp}',
          ),
          _Row(
            icon: Icons.local_fire_department,
            label: l.profileStatCurrentStreak,
            value: '${meta.currentStreak}',
          ),
          _Row(
            icon: Icons.emoji_events_outlined,
            label: l.profileStatBestStreak,
            value: '${meta.bestStreak}',
          ),
          _Row(
            icon: Icons.center_focus_strong_outlined,
            label: l.profileStatFocus,
            value: '${meta.focusScore}',
          ),
          _Row(
            icon: Icons.timeline,
            label: l.profileStatConsistency,
            value: '${meta.consistencyScore}',
          ),
          _Row(
            icon: Icons.monetization_on_outlined,
            label: l.profileStatCoins,
            value: '$coins',
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────
// Per-category XP grid
// ──────────────────────────────────────────────────────────────────────

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({required this.categories});
  final List<CategoryProgress> categories;

  static const _order = <CategoryId>[
    CategoryId.strength,
    CategoryId.mind,
    CategoryId.endurance,
    CategoryId.health,
    CategoryId.social,
    CategoryId.finance,
    CategoryId.creativity,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final byCat = {for (final c in categories) c.category: c};
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.profileCategoriesSectionTitle,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 10),
          for (final id in _order)
            _CategoryRow(
              progress: byCat[id] ??
                  CategoryProgress(category: id, xpTotal: 0, level: 1),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.progress});
  final CategoryProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Category levels in this MVP advance every 200 XP — same formula as
    // category_progress.level = floor(xp_total / 200) + 1. So progress
    // within the current level is xp_total mod 200 / 200.
    const xpPerLevel = 200;
    final inLevelXp = progress.xpTotal % xpPerLevel;
    final progressV = inLevelXp / xpPerLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryChip(category: progress.category, small: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.homeLevel(progress.level),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${progress.xpTotal} XP',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedFillBar(
            progress: progressV,
            height: 4,
            color: AppColors.categoryColor(progress.category.wire),
          ),
        ],
      ),
    );
  }
}
