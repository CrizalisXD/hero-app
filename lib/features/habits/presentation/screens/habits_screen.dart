import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../home/application/home_notifier.dart';
import '../../../rewards/application/achievements_notifier.dart';
import '../../../rewards/presentation/widgets/achievement_unlocked_sheet.dart';
import '../../application/habits_notifier.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_type.dart';
import '../widgets/create_habit_sheet.dart';
import '../widgets/habit_list_item.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  // ─── check-in ──────────────────────────────────────────────────────────────

  Future<void> _checkin(
    BuildContext context,
    WidgetRef ref,
    Habit h,
  ) async {
    try {
      final res =
          await ref.read(habitsNotifierProvider.notifier).checkin(h.id);
      if (!context.mounted || res == null || res.duplicate) return;
      final l = context.l10n;

      // Bad habit "check-in" = slip event: different message, no XP.
      final isBad = h.type == HabitType.bad;
      // Quiet floating snack. No "Undo" action — the slide-action /
      // tap-to-undo on the tile is the discoverable rollback path now.
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            content: Text(
              isBad
                  ? l.habitSlipSnack
                  : l.habitCheckinSuccessSnack(
                      res.totalXp,
                      l.habitStreakDays(res.currentStreak),
                    ),
            ),
          ),
        );
      // Keep Home (XP / streaks / today list) in sync after a check-in.
      ref.invalidate(homeNotifierProvider);
      if (res.unlockedAchievements.isNotEmpty && context.mounted) {
        await AchievementUnlockedSheet.showAll(
          context,
          res.unlockedAchievements,
        );
        ref.invalidate(achievementsNotifierProvider);
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.habitCheckinErrorSnack)),
      );
    }
  }

  // ─── uncheckin (undo) ──────────────────────────────────────────────────────

  Future<void> _uncheckin(
    BuildContext context,
    WidgetRef ref,
    Habit h,
  ) async {
    try {
      await ref.read(habitsNotifierProvider.notifier).uncheckin(h.id);
      ref.invalidate(homeNotifierProvider);
    } catch (_) {}
  }

  // ─── skip today ────────────────────────────────────────────────────────────

  Future<void> _skip(
    BuildContext context,
    WidgetRef ref,
    Habit h,
  ) async {
    try {
      await ref.read(habitsNotifierProvider.notifier).skipToday(h.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            content: Text(context.l10n.habitSkippedSnack),
          ),
        );
    } catch (_) {}
  }

  // ─── delete ────────────────────────────────────────────────────────────────

  /// Swipe-to-delete handler. UX matches TaskListItem so the gesture is
  /// consistent across the app. No confirm dialog — same as Tasks; the
  /// Dismissible widget itself gives the visual "are you sure" via the
  /// reveal of the red destructive background as the user drags.
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Habit h,
  ) async {
    await ref.read(habitsNotifierProvider.notifier).delete(h.id);
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(habitsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.habitsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateHabitSheet.show(context),
        icon: const Icon(Icons.add),
        label: Text(l.habitsFabCreate),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.habitsLoadError, textAlign: TextAlign.center),
          ),
        ),
        data: (view) {
          if (view.habits.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.habitsEmpty,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(habitsNotifierProvider.notifier).refresh(),
            child: ListView.separated(
              itemCount: view.habits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final h = view.habits[i];
                return HabitListItem(
                  habit: h,
                  checkedToday: view.checkedToday.contains(h.id),
                  onCheckin: () => _checkin(context, ref, h),
                  onUncheckin: () => _uncheckin(context, ref, h),
                  onSkip: () => _skip(context, ref, h),
                  onDelete: () => _delete(context, ref, h),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
