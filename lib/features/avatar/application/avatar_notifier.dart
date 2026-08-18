import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/supabase_avatar_repository.dart';
import '../domain/avatar_repository.dart';
import '../domain/models/avatar.dart';

part 'avatar_notifier.g.dart';

/// Avatar state notifier with optimistic primary-color update.
///
/// keepAlive: true — the avatar survives across route transitions
/// (AvatarScreen ↔ Home) so the cached value is reused instead of refetched.
@Riverpod(keepAlive: true)
class AvatarNotifier extends _$AvatarNotifier {
  AvatarRepository get _repo => ref.read(avatarFullRepositoryProvider);

  @override
  Future<Avatar> build() => _repo.getMine();

  /// Optimistic update. Returns true on success, false on rollback.
  Future<bool> updatePrimaryColor(String hex) async {
    final previous = state.value;
    if (previous == null) return false;

    // (1) Optimistic — show new color immediately.
    state = AsyncData(previous.copyWith(primaryColor: hex));

    try {
      // (2) Persist; replace state with the server-canonical row.
      final fresh = await _repo.updatePrimaryColor(hex);
      state = AsyncData(fresh);
      return true;
    } catch (_) {
      // (3) Rollback on any failure.
      state = AsyncData(previous);
      return false;
    }
  }

  /// Сохраняет полную конфигурацию внешности. Без оптимистичного апдейта:
  /// сервер может заменить несовместимые слоты дефолтами, и показать надо
  /// именно то, что реально сохранилось, а не то, что отправили.
  Future<bool> saveConfig(Avatar config) async {
    final previous = state.value;
    try {
      state = AsyncData(await _repo.saveConfig(config));
      return true;
    } catch (_) {
      if (previous != null) state = AsyncData(previous);
      return false;
    }
  }
}
