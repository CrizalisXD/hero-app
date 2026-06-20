import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import 'avatar_bridge.dart';
import 'avatar_stage_config.dart';

/// [AvatarBridge] backed by an embedded Unity view.
///
/// Forwards config/emotes to the Unity `AvatarController` GameObject and maps
/// Unity's string callbacks (see unity_assets/AvatarController.cs) back into
/// typed [AvatarEvent]s. Buffers the last config so it is (re)sent once Unity
/// signals `avatar:ready`.
class UnityAvatarBridge implements AvatarBridge {
  UnityWidgetController? _controller;
  final _events = StreamController<AvatarEvent>.broadcast();
  bool _ready = false;
  AvatarStageConfig? _pending;

  static const _gameObject = 'AvatarController';

  @override
  Stream<AvatarEvent> get events => _events.stream;

  @override
  bool get isReady => _ready;

  void attach(UnityWidgetController controller) {
    _controller = controller;
    if (_pending != null) sendConfig(_pending!);
  }

  /// Raw handler for [UnityWidget.onUnityMessage].
  void onUnityMessage(dynamic message) {
    final m = message.toString();
    debugPrint('[unity] message: $m');
    if (m == 'avatar:ready') {
      _ready = true;
      _events.add(const AvatarReady());
      if (_pending != null) sendConfig(_pending!);
    } else if (m == 'avatar:tapped') {
      _events.add(const AvatarTapped());
    } else if (m.startsWith('avatar:emote_finished:')) {
      _events.add(
        AvatarEmoteFinished(m.substring('avatar:emote_finished:'.length)),
      );
    }
  }

  @override
  Future<void> sendConfig(AvatarStageConfig config) async {
    _pending = config;
    await _controller?.postJsonMessage(
      _gameObject,
      'SetAvatarConfig',
      config.toJson(),
    );
  }

  @override
  Future<void> playEmote(AvatarEmote emote) async {
    await _controller?.postMessage(_gameObject, 'PlayEmote', emote.wire);
  }

  @override
  Future<void> dispose() async {
    await _events.close();
    _controller?.dispose();
  }
}
