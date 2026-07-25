import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_routines_repository.dart';
import '../domain/models/routine.dart';
import '../domain/models/routine_inputs.dart';

class RoutinesNotifier extends AsyncNotifier<RoutinesView> {
  late final _repo = ref.read(routinesRepositoryProvider);

  @override
  Future<RoutinesView> build() => _load();

  Future<RoutinesView> _load() async {
    final results = await Future.wait<Object>([
      _repo.listActive(),
      _repo.completedTodayIds(),
    ]);
    return RoutinesView(
      routines: results[0] as List<Routine>,
      completedToday: results[1] as Set<String>,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<Routine?> createRoutine(RoutineInput input) async {
    try {
      final created = await _repo.create(input);
      final cur = state.value;
      if (cur != null) {
        state = AsyncData(cur.copyWith(routines: [...cur.routines, created]));
      }
      return created;
    } catch (_) {
      return null;
    }
  }

  Future<Routine?> updateRoutine(String id, RoutineInput input) async {
    try {
      final updated = await _repo.update(id, input);
      final cur = state.value;
      if (cur != null) {
        state = AsyncData(
          cur.copyWith(
            routines: [
              for (final r in cur.routines)
                if (r.id == id) updated else r,
            ],
          ),
        );
      }
      return updated;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRoutine(String id) async {
    final cur = state.value;
    if (cur != null) {
      state = AsyncData(
        cur.copyWith(routines: cur.routines.where((r) => r.id != id).toList()),
      );
    }
    try {
      await _repo.delete(id);
    } catch (_) {
      await refresh();
    }
  }

  /// Marks the routine done for today. Returns null if already done or on
  /// error. Optimistically flips completedToday + bumps the local streak.
  Future<RoutineCompletionResult?> complete(String id) async {
    final cur = state.value;
    if (cur == null || cur.isDoneToday(id)) return null;
    try {
      final res = await _repo.complete(id);
      final cur2 = state.value;
      if (cur2 != null && !res.duplicate) {
        state = AsyncData(
          cur2.copyWith(
            completedToday: {...cur2.completedToday, id},
            routines: [
              for (final r in cur2.routines)
                if (r.id == id)
                  r.copyWith(currentStreak: res.currentStreak)
                else
                  r,
            ],
          ),
        );
      }
      return res;
    } catch (_) {
      return null;
    }
  }

  Future<void> uncomplete(String id) async {
    final cur = state.value;
    if (cur != null) {
      final newSet = {...cur.completedToday}..remove(id);
      state = AsyncData(cur.copyWith(completedToday: newSet));
    }
    try {
      await _repo.uncomplete(id);
    } catch (_) {
      await refresh();
    }
  }
}

final routinesNotifierProvider =
    AsyncNotifierProvider<RoutinesNotifier, RoutinesView>(
  RoutinesNotifier.new,
);
