import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:go_router/go_router.dart';

import 'avatar_stage_config.dart';
import 'unity_avatar_bridge.dart';

/// Embeds the Unity 3D hero into the [HeroAvatarStage] slot.
///
/// Self-contained: owns a [UnityAvatarBridge], pushes the [config] on create,
/// and routes an avatar tap (reported by Unity) to the avatar screen.
class UnityAvatarView extends StatefulWidget {
  const UnityAvatarView({super.key, required this.config});

  final AvatarStageConfig config;

  @override
  State<UnityAvatarView> createState() => _UnityAvatarViewState();
}

class _UnityAvatarViewState extends State<UnityAvatarView> {
  final _bridge = UnityAvatarBridge();

  @override
  void initState() {
    super.initState();
    _bridge.events.listen((e) {
      if (e is AvatarTapped && mounted) {
        GoRouter.of(context).push('/avatar');
      }
    });
  }

  @override
  void didUpdateWidget(covariant UnityAvatarView old) {
    super.didUpdateWidget(old);
    // Re-push config when level/color changes.
    if (old.config.level != widget.config.level ||
        old.config.primaryColor != widget.config.primaryColor) {
      _bridge.sendConfig(widget.config);
    }
  }

  @override
  void dispose() {
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnityWidget(
      onUnityCreated: (c) {
        _bridge.attach(c);
        _bridge.sendConfig(widget.config);
      },
      onUnityMessage: _bridge.onUnityMessage,
      fullscreen: false,
    );
  }
}
