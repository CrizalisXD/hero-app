import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_avatar_repository.dart';
import '../domain/avatar_repository.dart';
import '../domain/models/avatar.dart';

class AvatarNotifier extends AsyncNotifier<Avatar> {
  AvatarRepository get _repo => ref.read(avatarFullRepositoryProvider);

  @override
  Future<Avatar> build() => _repo.getMine();

  /// Оптимистичное обновление цвета. Возвращает true при успехе.
  Future<bool> updatePrimaryColor(String hex) async {
    final previous = state.value;
    if (previous == null) return false;

    // Optimistic update
    state = AsyncData(previous.copyWith(primaryColor: hex));
    try {
      final fresh = await _repo.updatePrimaryColor(hex);
      state = AsyncData(fresh);
      return true;
    } catch (_) {
      // Rollback
      state = AsyncData(previous);
      return false;
    }
  }
}

final avatarNotifierProvider =
    AsyncNotifierProvider<AvatarNotifier, Avatar>(AvatarNotifier.new);
