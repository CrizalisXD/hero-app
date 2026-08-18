import 'avatar_slot.dart';

/// Конфигурация внешности героя — одна строка `public.avatars`.
///
/// Хранит КАНОНИЧЕСКИЕ id ассетов (`male_hair_01`), а не имена Unity
/// GameObject: имена в сцене меняются при ре-экспорте и контрактом быть не
/// могут. Соответствие canonical id → Unity asset id живёт в каталоге
/// `avatar_assets`.
class Avatar {
  const Avatar({
    required this.userId,
    required this.renderer,
    required this.primaryColor,
    this.gender = AvatarGender.male,
    this.bodyType = kAvatarSlotEmpty,
    this.faceType = kAvatarSlotEmpty,
    this.skinColor = 'skin_01',
    this.hairType = kAvatarSlotEmpty,
    this.hairColor = '#362419',
    this.outfitType = kAvatarSlotEmpty,
    this.topType = kAvatarSlotEmpty,
    this.bottomType = kAvatarSlotEmpty,
    this.shoesType = kAvatarSlotEmpty,
    this.clothingType = kAvatarSlotEmpty,
  });

  final String userId;
  final String renderer;
  final String primaryColor;

  final AvatarGender gender;
  final String bodyType;
  final String faceType;
  final String skinColor;
  final String hairType;

  /// Hex-цвет волос, задаётся палитрой, а не каталогом.
  final String hairColor;

  /// Цельная вещь торс+ноги. Когда != [kAvatarSlotEmpty], [topType] и
  /// [bottomType] на модель не надеваются.
  final String outfitType;
  final String topType;
  final String bottomType;
  final String shoesType;

  /// DEPRECATED: заменён на [outfitType]/[topType]/[bottomType]/[shoesType].
  /// Читается из БД ради старых строк; в UI не используется.
  final String clothingType;

  /// true — надет цельный аутфит, слоты верха и низа скрыты в редакторе.
  bool get hasOutfit => outfitType != kAvatarSlotEmpty;

  /// Значение слота в этой конфигурации.
  String slotValue(AvatarSlot slot) => switch (slot) {
        AvatarSlot.body => bodyType,
        AvatarSlot.face => faceType,
        AvatarSlot.skin => skinColor,
        AvatarSlot.hair => hairType,
        AvatarSlot.outfit => outfitType,
        AvatarSlot.top => topType,
        AvatarSlot.bottom => bottomType,
        AvatarSlot.shoes => shoesType,
      };

  /// Устанавливает слот по значению. Надевание аутфита снимает верх и низ, и
  /// наоборот — иначе на модели окажутся два пересекающихся меша.
  Avatar withSlot(AvatarSlot slot, String value) => switch (slot) {
        AvatarSlot.body => copyWith(bodyType: value),
        AvatarSlot.face => copyWith(faceType: value),
        AvatarSlot.skin => copyWith(skinColor: value),
        AvatarSlot.hair => copyWith(hairType: value),
        AvatarSlot.outfit => copyWith(
            outfitType: value,
            topType: value == kAvatarSlotEmpty ? topType : kAvatarSlotEmpty,
            bottomType:
                value == kAvatarSlotEmpty ? bottomType : kAvatarSlotEmpty,
          ),
        AvatarSlot.top =>
          copyWith(topType: value, outfitType: kAvatarSlotEmpty),
        AvatarSlot.bottom =>
          copyWith(bottomType: value, outfitType: kAvatarSlotEmpty),
        AvatarSlot.shoes => copyWith(shoesType: value),
      };

  Avatar copyWith({
    AvatarGender? gender,
    String? bodyType,
    String? faceType,
    String? skinColor,
    String? hairType,
    String? hairColor,
    String? outfitType,
    String? topType,
    String? bottomType,
    String? shoesType,
    String? primaryColor,
    String? renderer,
  }) =>
      Avatar(
        userId: userId,
        renderer: renderer ?? this.renderer,
        primaryColor: primaryColor ?? this.primaryColor,
        gender: gender ?? this.gender,
        bodyType: bodyType ?? this.bodyType,
        faceType: faceType ?? this.faceType,
        skinColor: skinColor ?? this.skinColor,
        hairType: hairType ?? this.hairType,
        hairColor: hairColor ?? this.hairColor,
        outfitType: outfitType ?? this.outfitType,
        topType: topType ?? this.topType,
        bottomType: bottomType ?? this.bottomType,
        shoesType: shoesType ?? this.shoesType,
        clothingType: clothingType,
      );

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        userId: json['user_id'] as String,
        renderer: json['renderer'] as String? ?? 'placeholder',
        primaryColor: json['primary_color'] as String? ?? '#7F77DD',
        gender: AvatarGender.fromWire(json['avatar_gender'] as String?),
        bodyType: json['body_type'] as String? ?? kAvatarSlotEmpty,
        faceType: json['face_type'] as String? ?? kAvatarSlotEmpty,
        skinColor: json['skin_color'] as String? ?? 'skin_01',
        hairType: json['hair_type'] as String? ?? kAvatarSlotEmpty,
        hairColor: json['hair_color'] as String? ?? '#362419',
        outfitType: json['outfit_type'] as String? ?? kAvatarSlotEmpty,
        topType: json['top_type'] as String? ?? kAvatarSlotEmpty,
        bottomType: json['bottom_type'] as String? ?? kAvatarSlotEmpty,
        shoesType: json['shoes_type'] as String? ?? kAvatarSlotEmpty,
        clothingType: json['clothing_type'] as String? ?? kAvatarSlotEmpty,
      );

  /// Параметры RPC `save_avatar_config`. Порядок и имена — часть контракта
  /// с миграцией 20260815000001.
  Map<String, dynamic> toRpcParams() => {
        'p_gender': gender.wire,
        'p_body_type': bodyType,
        'p_skin_color': skinColor,
        'p_hair_type': hairType,
        'p_hair_color': hairColor,
        'p_outfit_type': outfitType,
        'p_top_type': topType,
        'p_bottom_type': bottomType,
        'p_shoes_type': shoesType,
        'p_primary_color': primaryColor,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Avatar &&
          other.userId == userId &&
          other.renderer == renderer &&
          other.primaryColor == primaryColor &&
          other.gender == gender &&
          other.bodyType == bodyType &&
          other.faceType == faceType &&
          other.skinColor == skinColor &&
          other.hairType == hairType &&
          other.hairColor == hairColor &&
          other.outfitType == outfitType &&
          other.topType == topType &&
          other.bottomType == bottomType &&
          other.shoesType == shoesType;

  @override
  int get hashCode => Object.hash(
        userId,
        renderer,
        primaryColor,
        gender,
        bodyType,
        faceType,
        skinColor,
        hairType,
        hairColor,
        outfitType,
        topType,
        bottomType,
        shoesType,
      );
}
