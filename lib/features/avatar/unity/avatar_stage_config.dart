/// Immutable description of how the hero avatar should be rendered.
///
/// This is the **contract** sent across the Flutter↔Unity bridge (as JSON) and
/// is also consumed by the 2D placeholder renderer. Keeping it renderer-neutral
/// means the same config drives the placeholder today and Unity later.
///
/// Field names mirror the `avatars` table (TZ §22.2) so a DB row maps 1:1.
class AvatarStageConfig {
  const AvatarStageConfig({
    required this.primaryColor,
    required this.level,
    this.renderer = 'placeholder',
    this.bodyType = 'default',
    this.faceType = 'default',
    this.hairType = 'default',
    this.clothingType = 'default',
    this.unityAvatarId,
  });

  /// Hex string like `#7F77DD`.
  final String primaryColor;
  final int level;

  /// 'placeholder' | 'rive' | 'unity'
  final String renderer;
  final String bodyType;
  final String faceType;
  final String hairType;
  final String clothingType;

  /// Opaque id of a pre-built Unity avatar asset, when [renderer] == 'unity'.
  final String? unityAvatarId;

  /// JSON payload sent to Unity (`SetAvatarConfig` message). Unity's C# bridge
  /// deserializes this exact shape.
  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColor,
        'level': level,
        'renderer': renderer,
        'bodyType': bodyType,
        'faceType': faceType,
        'hairType': hairType,
        'clothingType': clothingType,
        if (unityAvatarId != null) 'unityAvatarId': unityAvatarId,
      };

  AvatarStageConfig copyWith({String? primaryColor, int? level}) =>
      AvatarStageConfig(
        primaryColor: primaryColor ?? this.primaryColor,
        level: level ?? this.level,
        renderer: renderer,
        bodyType: bodyType,
        faceType: faceType,
        hairType: hairType,
        clothingType: clothingType,
        unityAvatarId: unityAvatarId,
      );
}

/// One-shot animations the app asks the avatar to play.
enum AvatarEmote { idle, taskDone, levelUp, wave }

extension AvatarEmoteWire on AvatarEmote {
  /// Wire name sent to Unity (`PlayEmote` message argument).
  String get wire => switch (this) {
        AvatarEmote.idle => 'idle',
        AvatarEmote.taskDone => 'task_done',
        AvatarEmote.levelUp => 'level_up',
        AvatarEmote.wave => 'wave',
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
