import 'dart:async';

import 'avatar_stage_config.dart';

/// Abstraction over the avatar renderer transport.
///
/// The app talks to the avatar only through this interface, so the underlying
/// renderer (placeholder / Unity) is an implementation detail:
///   • [NoopAvatarBridge] — used while the avatar is the 2D placeholder;
///   • `UnityAvatarBridge` — added in `UNITY_SETUP.md` once the Unity export is
///     in place; it forwards [sendConfig]/[playEmote] over the
///     `flutter_unity_widget` message channel and maps Unity callbacks to
///     [events].
///
/// Keeping this in pure Dart means the rest of the app compiles and runs with
/// zero Unity dependencies until the integration is switched on.
abstract class AvatarBridge {
  /// Events coming back from the renderer (ready / tapped / emote finished).
  Stream<AvatarEvent> get events;

  /// Whether the renderer is loaded and ready to receive messages.
  bool get isReady;

  /// Push a new avatar configuration to the renderer.
  Future<void> sendConfig(AvatarStageConfig config);

  /// Ask the renderer to play a one-shot emote (idle/level-up/etc.).
  Future<void> playEmote(AvatarEmote emote);

  /// Release any native resources.
  Future<void> dispose();
}

/// Inert bridge used by the placeholder renderer. Records the last config so a
/// real bridge can replay it on attach, but performs no native work.
class NoopAvatarBridge implements AvatarBridge {
  final _controller = StreamController<AvatarEvent>.broadcast();

  AvatarStageConfig? lastConfig;
  AvatarEmote? lastEmote;

  @override
  Stream<AvatarEvent> get events => _controller.stream;

  @override
  bool get isReady => true;

  @override
  Future<void> sendConfig(AvatarStageConfig config) async {
    lastConfig = config;
  }

  @override
  Future<void> playEmote(AvatarEmote emote) async {
    lastEmote = emote;
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
