/// Слоты внешности героя и пол персонажа.
///
/// Wire-значения совпадают со строками в `avatar_assets.type` и
/// `avatars.avatar_gender` — парсинг и сериализация идут только через них,
/// чтобы переименование в Dart никогда не разъезжалось с базой.
library;

enum AvatarSlot {
  body('body'),
  face('face'),
  skin('skin'),
  hair('hair'),

  /// Цельная вещь на торс+ноги (платье, костюм). Исключает [top]/[bottom].
  outfit('outfit'),
  top('top'),
  bottom('bottom'),
  shoes('shoes');

  const AvatarSlot(this.wire);
  final String wire;

  static AvatarSlot? tryParse(String? wire) {
    for (final s in AvatarSlot.values) {
      if (s.wire == wire) return s;
    }
    return null;
  }

  /// Слоты, которые пользователь меняет в редакторе, в порядке вкладок.
  /// [body] и [face] сюда не входят: тело задаётся выбором пола, а лиц в
  /// каталоге пока нет.
  static const editable = <AvatarSlot>[
    AvatarSlot.hair,
    AvatarSlot.skin,
    AvatarSlot.outfit,
    AvatarSlot.top,
    AvatarSlot.bottom,
    AvatarSlot.shoes,
  ];
}

/// Пол ПЕРСОНАЖА — не пользователя. Определяет базовый меш и набор
/// совместимых ассетов.
enum AvatarGender {
  male('male'),
  female('female');

  const AvatarGender(this.wire);
  final String wire;

  static AvatarGender fromWire(String? wire) =>
      wire == 'female' ? AvatarGender.female : AvatarGender.male;
}

/// Совместимость ассета с полом. `unisex` подходит обоим.
enum AssetGender {
  male('male'),
  female('female'),
  unisex('unisex');

  const AssetGender(this.wire);
  final String wire;

  static AssetGender fromWire(String? wire) => switch (wire) {
        'male' => AssetGender.male,
        'female' => AssetGender.female,
        _ => AssetGender.unisex,
      };

  bool fits(AvatarGender gender) =>
      this == AssetGender.unisex || wire == gender.wire;
}

/// Как предмет открывается. `store`/`level`/`achievement` пока только
/// размечены в каталоге — логика разблокировки идёт отдельным этапом.
enum AssetUnlockType {
  byDefault('default'),
  level('level'),
  achievement('achievement'),
  store('store');

  const AssetUnlockType(this.wire);
  final String wire;

  static AssetUnlockType fromWire(String? wire) => switch (wire) {
        'level' => AssetUnlockType.level,
        'achievement' => AssetUnlockType.achievement,
        'store' => AssetUnlockType.store,
        _ => AssetUnlockType.byDefault,
      };
}

/// Значение слота, когда ничего не надето / контента ещё нет.
const String kAvatarSlotEmpty = 'default';
