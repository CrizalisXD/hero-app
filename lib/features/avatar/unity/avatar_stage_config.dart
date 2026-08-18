import '../domain/models/avatar.dart';

/// Immutable description of how the hero avatar should be rendered.
///
/// This is the **contract** sent across the Flutter↔Unity bridge (as JSON) and
/// is also consumed by the 2D placeholder renderer. Keeping it renderer-neutral
/// means the same config drives the placeholder today and Unity later.
///
/// Field names mirror the `avatars` table (TZ §22.2) so a DB row maps 1:1, and
/// they are deserialized verbatim by `AvatarConfig` in Unity's
/// `AvatarController.cs` — renaming one side without the other silently drops
/// the field.
class AvatarStageConfig {
  const AvatarStageConfig({
    required this.primaryColor,
    required this.level,
    this.renderer = 'placeholder',
    this.gender = 'male',
    this.bodyType = 'default',
    this.faceType = 'default',
    this.skinColor = 'skin_01',
    this.hairType = 'default',
    this.hairColor = '#362419',
    this.outfitType = 'default',
    this.topType = 'default',
    this.bottomType = 'default',
    this.shoesType = 'default',
    this.clothingType = 'default',
    this.unityAvatarId,
  });

  /// Everything Unity needs to dress the hero, straight from the stored row.
  factory AvatarStageConfig.fromAvatar(Avatar avatar, {required int level}) =>
      AvatarStageConfig(
        primaryColor: avatar.primaryColor,
        level: level,
        renderer: 'unity',
        gender: avatar.gender.wire,
        bodyType: avatar.bodyType,
        faceType: avatar.faceType,
        skinColor: avatar.skinColor,
        hairType: avatar.hairType,
        hairColor: avatar.hairColor,
        outfitType: avatar.outfitType,
        topType: avatar.topType,
        bottomType: avatar.bottomType,
        shoesType: avatar.shoesType,
        clothingType: avatar.clothingType,
      );

  /// Hex string like `#7F77DD`.
  final String primaryColor;
  final int level;

  /// 'placeholder' | 'rive' | 'unity'
  final String renderer;

  /// 'male' | 'female' — selects the base mesh AND the skeleton in Unity.
  final String gender;

  final String bodyType;
  final String faceType;

  /// Skin tone id (`skin_01`..`skin_03`), a texture swap on the body.
  final String skinColor;

  final String hairType;

  /// Hex hair colour — the hair meshes are tinted, not duplicated per colour.
  final String hairColor;

  /// Full-body piece. When set (≠ `'default'`), Unity ignores
  /// [topType]/[bottomType], mirroring the exclusivity in [Avatar.withSlot].
  final String outfitType;
  final String topType;
  final String bottomType;
  final String shoesType;

  /// DEPRECATED: superseded by the outfit/top/bottom/shoes slots. Still sent so
  /// an older Unity export keeps rendering something sensible.
  final String clothingType;

  /// Opaque id of a pre-built Unity avatar asset, when [renderer] == 'unity'.
  final String? unityAvatarId;

  /// JSON payload sent to Unity (`SetAvatarConfig` message). Unity's C# bridge
  /// deserializes this exact shape.
  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColor,
        'level': level,
        'renderer': renderer,
        'gender': gender,
        'bodyType': bodyType,
        'faceType': faceType,
        'skinColor': skinColor,
        'hairType': hairType,
        'hairColor': hairColor,
        'outfitType': outfitType,
        'topType': topType,
        'bottomType': bottomType,
        'shoesType': shoesType,
        'clothingType': clothingType,
        if (unityAvatarId != null) 'unityAvatarId': unityAvatarId,
      };

  AvatarStageConfig copyWith({String? primaryColor, int? level}) =>
      AvatarStageConfig(
        primaryColor: primaryColor ?? this.primaryColor,
        level: level ?? this.level,
        renderer: renderer,
        gender: gender,
        bodyType: bodyType,
        faceType: faceType,
        skinColor: skinColor,
        hairType: hairType,
        hairColor: hairColor,
        outfitType: outfitType,
        topType: topType,
        bottomType: bottomType,
        shoesType: shoesType,
        clothingType: clothingType,
        unityAvatarId: unityAvatarId,
      );

  /// Value equality is what tells the Unity view a re-send is needed — without
  /// it a wardrobe change would never reach the engine.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarStageConfig &&
          other.primaryColor == primaryColor &&
          other.level == level &&
          other.renderer == renderer &&
          other.gender == gender &&
          other.bodyType == bodyType &&
          other.faceType == faceType &&
          other.skinColor == skinColor &&
          other.hairType == hairType &&
          other.hairColor == hairColor &&
          other.outfitType == outfitType &&
          other.topType == topType &&
          other.bottomType == bottomType &&
          other.shoesType == shoesType &&
          other.unityAvatarId == unityAvatarId;

  @override
  int get hashCode => Object.hash(
        primaryColor,
        level,
        renderer,
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
        unityAvatarId,
      );
}

/// One-shot animations the app asks the avatar to play.
enum AvatarEmote { idle, taskDone, levelUp, wave, upset }

extension AvatarEmoteWire on AvatarEmote {
  /// Wire name sent to Unity (`PlayEmote` message argument).
  String get wire => switch (this) {
        AvatarEmote.idle => 'idle',
        AvatarEmote.taskDone => 'task_done',
        AvatarEmote.levelUp => 'level_up',
        AvatarEmote.wave => 'wave',
        AvatarEmote.upset => 'upset',
      };
}

/// Events emitted *from* the avatar renderer back to Flutter.
sealed class AvatarEvent {
  const AvatarEvent();
}

/// Renderer finished loading and is ready to receive config/emotes.
class AvatarReady extends AvatarEvent {
  const AvatarReady();
}

/// User tapped the avatar (e.g. open the avatar/customization screen).
class AvatarTapped extends AvatarEvent {
  const AvatarTapped();
}

/// A previously requested emote finished playing.
class AvatarEmoteFinished extends AvatarEvent {
  const AvatarEmoteFinished(this.emote);
  final String emote;
}
