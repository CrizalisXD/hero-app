import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_habits_repository.dart';
import '../domain/models/create_habit_input.dart';
import '../domain/models/habit.dart';
import '../domain/models/habit_checkin_result.dart';
import '../domain/models/habits_view.dart';

// ── empty view constant ───────────────────────────────────────────────────────
const _emptyView = HabitsView(habits: [], checkedToday: <String>{});

// ── notifier ──────────────────────────────────────────────────────────────────

class HabitsNotifier extends AsyncNotifier<HabitsView> {
  late final _repo = ref.read(habitsRepositoryProvider);

  @override
  Future<HabitsView> build() => _load();

  Future<HabitsView> _load() async {
    // Fetch both in parallel.
    final results = await Future.wait<Object>([
      _repo.listActive(),
      _repo.habitIdsCheckedToday(),
    ]);
    return HabitsView(
      habits: results[0] as List<Habit>,
      checkedToday: results[1] as Set<String>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Optimistic insert: prepends the new habit to the list.
  Future<Habit?> createHabit(CreateHabitInput input) async {
    try {
      final created = await _repo.create(input);
      final current = state.value ?? _emptyView;
      state = AsyncData(
        current.copyWith(habits: [created, ...current.habits]),
      );
      return created;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// Optimistic check-in + rollback on error.
  /// Returns null if the habit is already checked today.
  Future<HabitCheckinResult?> checkin(String habitId) async {
    final previous = state.value;
    if (previous == null) return null;
    if (previous.checkedToday.contains(habitId)) return null;

    // 1. Optimistic update.
    final optimisticChecked = {...previous.checkedToday, habitId};
    final optimisticHabits = previous.habits.map((h) {
      if (h.id != habitId) return h;
      return h.copyWith(currentStreak: h.currentStreak + 1);
    }).toList();
    state = AsyncData(
      previous.copyWith(
        habits: optimisticHabits,
        checkedToday: optimisticChecked,
      ),
    );

    // 2. Server call.
    try {
      final res = await _repo.checkin(habitId);

      // Sync streak from server (handles duplicate / day-rollover edge cases).
      final freshHabits = state.value!.habits.map((h) {
        if (h.id != habitId) return h;
        return h.copyWith(currentStreak: res.currentStreak);
      }).toList();
      state = AsyncData(state.value!.copyWith(habits: freshHabits));
      return res;
    } catch (_) {
      // Rollback on error.
      state = AsyncData(previous);
      rethrow;
    }
  }

  /// Optimistic delete + rollback on error.
  Future<void> delete(String habitId) async {
    final previous = state.value;
    if (previous == null) return;

    state = AsyncData(
      previous.copyWith(
        habits: previous.habits.where((h) => h.id != habitId).toList(),
        checkedToday:
            previous.checkedToday.where((id) => id != habitId).toSet(),
      ),
    );
    try {
      await _repo.delete(habitId);
    } catch (_) {
      state = AsyncData(previous);
      rethrow;
    }
  }
}

// ── provider ──────────────────────────────────────────────────────────────────

final habitsNotifierProvider =
    AsyncNotifierProvider<HabitsNotifier, HabitsView>(HabitsNotifier.new);
