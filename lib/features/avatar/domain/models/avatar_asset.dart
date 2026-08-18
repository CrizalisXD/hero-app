import 'avatar_slot.dart';

/// Одна позиция каталога `public.avatar_assets`.
///
/// Каталог read-only для клиента: наполняется миграциями. Пока под предмет
/// нет меша, строка живёт с `is_enabled = false` и в выборку не попадает —
/// так каталог наполняется заранее, не ломая редактор пустыми карточками.
class AvatarAsset {
  const AvatarAsset({
    required this.id,
    required this.slot,
    required this.gender,
    required this.unlockType,
    this.unityAssetId,
    this.previewUrl,
    this.isDefault = false,
    this.unlockValue,
    this.priceCoins = 0,
    this.rarity = 'common',
    this.sortOrder = 0,
  });

  /// Канонический id — то, что лежит в строке пользователя.
  final String id;
  final AvatarSlot slot;
  final AssetGender gender;
  final AssetUnlockType unlockType;

  /// Имя объекта в Unity. Меняется при ре-экспорте, поэтому не хранится в
  /// конфигурации пользователя.
  final String? unityAssetId;
  final String? previewUrl;
  final bool isDefault;
  final String? unlockValue;
  final int priceCoins;
  final String rarity;
  final int sortOrder;

  /// Заблокированные предметы показываются, но не применяются (ТЗ §5).
  /// Разблокировка по уровню/ачивке/покупке — отдельный этап, поэтому
  /// сейчас заперто всё, что не `default`.
  bool get isLocked => unlockType != AssetUnlockType.byDefault;

  bool fitsGender(AvatarGender g) => gender.fits(g);

  static AvatarAsset? tryFromJson(Map<String, dynamic> json) {
    final slot = AvatarSlot.tryParse(json['type'] as String?);
    // Неизвестный слот — это каталог новее клиента. Пропускаем строку, а не
    // роняем весь редактор.
    if (slot == null) return null;
    return AvatarAsset(
      id: json['id'] as String,
      slot: slot,
      gender: AssetGender.fromWire(json['gender'] as String?),
      unlockType: AssetUnlockType.fromWire(json['unlock_type'] as String?),
      unityAssetId: json['unity_asset_id'] as String?,
      previewUrl: json['preview_url'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      unlockValue: json['unlock_value'] as String?,
      priceCoins: (json['price_coins'] as num?)?.toInt() ?? 0,
      rarity: json['rarity'] as String? ?? 'common',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Каталог, разложенный по слотам, — то, чем оперируют экраны.
class AvatarCatalog {
  const AvatarCatalog(this._bySlot);

  final Map<AvatarSlot, List<AvatarAsset>> _bySlot;

  static const empty = AvatarCatalog({});

  factory AvatarCatalog.fromRows(List<Map<String, dynamic>> rows) {
    final bySlot = <AvatarSlot, List<AvatarAsset>>{};
    for (final row in rows) {
      final asset = AvatarAsset.tryFromJson(row);
      if (asset == null) continue;
      (bySlot[asset.slot] ??= []).add(asset);
    }
    for (final list in bySlot.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    return AvatarCatalog(bySlot);
  }

  /// Предметы слота, подходящие полу. Пустой список означает «контента под
  /// этот слот ещё нет» — вкладку в редакторе показывать не нужно.
  List<AvatarAsset> forSlot(AvatarSlot slot, AvatarGender gender) =>
      (_bySlot[slot] ?? const []).where((a) => a.fitsGender(gender)).toList();

  /// Слоты, в которых для этого пола есть хоть один предмет.
  List<AvatarSlot> availableSlots(AvatarGender gender) => [
        for (final slot in AvatarSlot.editable)
          if (forSlot(slot, gender).isNotEmpty) slot,
      ];

  /// Дефолт слота для пола — то, чем заменяется несовместимый предмет.
  /// Зеркалит `public.avatar_asset_or_default()`: клиент валидирует первым,
  /// сервер перепроверяет.
  String defaultFor(AvatarSlot slot, AvatarGender gender) {
    final candidates = forSlot(slot, gender);
    if (candidates.isEmpty) return kAvatarSlotEmpty;
    final exact = candidates
        .where((a) => a.isDefault && a.gender.wire == gender.wire)
        .firstOrNull;
    final any = candidates.where((a) => a.isDefault).firstOrNull;
    return (exact ?? any ?? candidates.first).id;
  }

  /// Есть ли предмет в каталоге, совместим ли он с полом и не заперт ли.
  bool isSelectable(AvatarSlot slot, String assetId, AvatarGender gender) {
    if (assetId == kAvatarSlotEmpty) return true;
    final asset =
        forSlot(slot, gender).where((a) => a.id == assetId).firstOrNull;
    return asset != null && !asset.isLocked;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
