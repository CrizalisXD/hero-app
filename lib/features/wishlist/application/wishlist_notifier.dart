import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../categories/domain/models/category_id.dart';
import '../../categories/domain/models/xp_inputs.dart';
import '../../tasks/application/tasks_notifier.dart';
import '../../tasks/domain/models/create_task_input.dart';
import '../data/supabase_wishlist_repository.dart';
import '../domain/wishlist_item.dart';

class WishlistNotifier extends AsyncNotifier<List<WishlistItem>> {
  SupabaseWishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  @override
  Future<List<WishlistItem>> build() => _repo.list();

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _repo.list());
  }

  /// Мгновенный захват идеи — оптимистично в начало списка.
  Future<bool> add(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return false;
    try {
      final item = await _repo.add(trimmed);
      state = AsyncData([item, ...state.valueOrNull ?? []]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleTried(String id) async {
    final current = state.valueOrNull ?? const <WishlistItem>[];
    final item = current.where((e) => e.id == id).firstOrNull;
    if (item == null) return;
    final tried = !item.isTried;
    // WishlistItem.copyWith не умеет null-ить triedAt — пересобираем руками.
    state = AsyncData([
      for (final e in current)
        if (e.id == id)
          WishlistItem(
            id: e.id,
            title: e.title,
            createdAt: e.createdAt,
            triedAt: tried ? DateTime.now() : null,
            convertedTaskId: e.convertedTaskId,
          )
        else
          e,
    ]);
    try {
      await _repo.markTried(id, tried: tried);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> delete(String id) async {
    final current = state.valueOrNull ?? const <WishlistItem>[];
    state = AsyncData(current.where((e) => e.id != id).toList());
    try {
      await _repo.delete(id);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  /// Превращает идею в задачу (обычная задача, категория подберётся
  /// сервером/классификатором позже — тут mind-фолбэк, XP считает сервер).
  Future<bool> convertToTask(String id) async {
    final current = state.valueOrNull ?? const <WishlistItem>[];
    final item = current.where((e) => e.id == id).firstOrNull;
    if (item == null || item.isConverted) return false;

    final task = await ref.read(tasksNotifierProvider.notifier).createTask(
          CreateTaskInput(
            title: item.title,
            mainCategory: CategoryId.mind,
            difficulty: TaskDifficulty.normal,
            duration: TaskDuration.medium,
            importance: TaskImportance.normal,
            xpReward: 20,
          ),
        );
    if (task == null) return false;

    state = AsyncData([
      for (final e in current)
        if (e.id == id) e.copyWith(convertedTaskId: task.id) else e,
    ]);
    try {
      await _repo.linkTask(id, task.id);
    } catch (_) {
      // Задача уже создана — потеря линка не критична.
    }
    return true;
  }
}

final wishlistNotifierProvider =
    AsyncNotifierProvider<WishlistNotifier, List<WishlistItem>>(
  WishlistNotifier.new,
);
