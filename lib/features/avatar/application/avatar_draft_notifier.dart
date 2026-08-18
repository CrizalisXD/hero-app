import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supabase_avatar_repository.dart';
import '../domain/models/avatar.dart';
import '../domain/models/avatar_asset.dart';
import '../domain/models/avatar_slot.dart';
import 'avatar_notifier.dart';

/// Черновик редактора внешности.
///
/// Разделение по ТЗ §9: [avatarNotifierProvider] — то, что лежит в бэкенде,
/// [avatarDraftProvider] — то, что пользователь крутит прямо сейчас. Unity
/// подписан на черновик, поэтому изменения видны на модели до сохранения, а
/// Back просто выбрасывает черновик, не трогая сохранённое.
class AvatarDraftNotifier extends Notifier<Avatar?> {
  @override
  Avatar? build() => null;

  AvatarCatalog get _catalog =>
      ref.read(avatarCatalogProvider).valueOrNull ?? AvatarCatalog.empty;

  /// Открытие редактора: копируем сохранённую конфигурацию в черновик.
  /// Повторный вызов при уже открытом черновике ничего не делает — иначе
  /// пересборка виджета сбрасывала бы правки пользователя.
  void begin(Avatar saved) {
    state ??= saved;
  }

  /// Принудительно начать заново от сохранённого состояния.
  void reset(Avatar saved) => state = saved;

  void discard() => state = null;

  void setSlot(AvatarSlot slot, String assetId) {
    final current = state;
    if (current == null) return;
    // Заблокированные и несовместимые предметы не применяются (ТЗ §5).
    if (!_catalog.isSelectable(slot, assetId, current.gender)) return;
    state = current.withSlot(slot, assetId);
  }

  void setHairColor(String hex) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(hairColor: hex);
  }

  void setPrimaryColor(String hex) {
    final current = state;
    if (current == null) return;
    state = current.copyWith(primaryColor: hex);
  }

  /// Смена пола меняет базовый меш и весь набор совместимых предметов, так
  /// что несовместимое приходится сбрасывать на валидные дефолты (ТЗ §11).
  /// Возвращает слоты, которые пришлось сбросить, — вызывающий показывает
  /// это пользователю, а не молча подменяет вещи.
  List<AvatarSlot> setGender(AvatarGender gender) {
    final current = state;
    if (current == null) return const [];
    if (current.gender == gender) return const [];

    var next = current.copyWith(gender: gender);
    final resetSlots = <AvatarSlot>[];

    for (final slot in [AvatarSlot.body, ...AvatarSlot.editable]) {
      final value = next.slotValue(slot);
      if (value == kAvatarSlotEmpty) continue;
      if (_catalog.isSelectable(slot, value, gender)) continue;
      next = next.withSlot(slot, _catalog.defaultFor(slot, gender));
      resetSlots.add(slot);
    }
    // Тело не редактируется вручную — оно всегда следует за полом.
    next = next.withSlot(
      AvatarSlot.body,
      _catalog.defaultFor(AvatarSlot.body, gender),
    );

    state = next;
    return resetSlots;
  }

  /// Приводит черновик к валидному состоянию: всё несовместимое, запертое
  /// или отсутствующее в каталоге заменяется дефолтом для текущего пола.
  /// Вызывается перед сохранением — сервер проверит это же ещё раз.
  Avatar validated(Avatar avatar) {
    var next = avatar;
    for (final slot in [AvatarSlot.body, ...AvatarSlot.editable]) {
      final value = next.slotValue(slot);
      if (value == kAvatarSlotEmpty) continue;
      if (_catalog.isSelectable(slot, value, avatar.gender)) continue;
      next = next.withSlot(slot, _catalog.defaultFor(slot, avatar.gender));
    }
    return next;
  }

  /// Сохранение: persist черновика и синхронизация сохранённого состояния.
  /// Черновик остаётся жить, чтобы экран не мигнул на время запроса; чистит
  /// его вызывающий после успешного ухода с экрана.
  Future<bool> save() async {
    final draft = state;
    if (draft == null) return false;
    final ok = await ref
        .read(avatarNotifierProvider.notifier)
        .saveConfig(validated(draft));
    if (ok) state = ref.read(avatarNotifierProvider).valueOrNull ?? draft;
    return ok;
  }
}

final avatarDraftProvider =
    NotifierProvider<AvatarDraftNotifier, Avatar?>(AvatarDraftNotifier.new);
