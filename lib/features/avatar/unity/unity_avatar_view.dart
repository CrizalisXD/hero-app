import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

import '../../../../../app/theme/app_colors.dart';
import 'avatar_stage_config.dart';
import 'unity_avatar_bridge.dart';

/// Embeds the Unity 3D hero into the [HeroAvatarStage] slot.
///
/// Perceived-perf details:
///   • a branded loading overlay covers the slot until Unity has rendered, so
///     Home never shows a black/empty box while the engine cold-starts;
///   • `unloadOnDispose: false` keeps Unity warm across tab switches, so
///     returning to Home doesn't re-boot the engine.
class UnityAvatarView extends StatefulWidget {
  const UnityAvatarView({super.key, required this.config});

  final AvatarStageConfig config;

  @override
  State<UnityAvatarView> createState() => _UnityAvatarViewState();
}

/// Fraction of the view width to nudge the Unity scene horizontally. The scene
/// now centres the avatar itself, so this is 0; bump it only if a future
/// export frames the hero off-centre.
const double _shiftFraction = 0.0;

class _UnityAvatarViewState extends State<UnityAvatarView> {
  final _bridge = UnityAvatarBridge();
  StreamSubscription<AvatarEvent>? _sub;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _sub = _bridge.events.listen((e) {
      if (e is AvatarReady && mounted) {
        setState(() => _loading = false);
      }
      // Tapping the hero is intentionally a no-op: the avatar screen/route was
      // removed, so a tap no longer navigates anywhere.
    });
  }

  @override
  void didUpdateWidget(covariant UnityAvatarView old) {
    super.didUpdateWidget(old);
    if (old.config.level != widget.config.level ||
        old.config.primaryColor != widget.config.primaryColor) {
      _bridge.sendConfig(widget.config);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _bridge.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The avatar is framed left-of-centre in the Unity scene; nudge the
        // whole Unity view right so the hero sits centred in the slot. Tune
        // [_shiftFraction] if a re-export changes the framing.
        FractionalTranslation(
          translation: const Offset(_shiftFraction, 0),
          child: UnityWidget(
            onUnityCreated: (c) {
            debugPrint('[unity] UnityWidget created — sending config');
            _bridge.attach(c);
            _bridge.sendConfig(widget.config);
            // Reveal Unity once the first frame has had a moment to render,
            // even if the scene never sends avatar:ready.
            Future.delayed(const Duration(milliseconds: 600), () {
              if (mounted) setState(() => _loading = false);
            });
          },
            onUnityMessage: _bridge.onUnityMessage,
            onUnityUnloaded: () => debugPrint('[unity] unloaded'),
            unloadOnDispose: false,
            fullscreen: false,
          ),
        ),
        AnimatedOpacity(
          opacity: _loading ? 1 : 0,
          duration: const Duration(milliseconds: 350),
          child: IgnorePointer(
            ignoring: !_loading,
            child: const _UnityLoadingOverlay(),
          ),
        ),
      ],
    );
  }
}

/// Cheap branded overlay shown during Unity cold-start.
class _UnityLoadingOverlay extends StatelessWidget {
  const _UnityLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    // Transparent overlay (no opaque fill) so the Flutter background stays
    // visible while Unity cold-starts — no black box.
    return Center(
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.accent.withValues(alpha: 0.18),
              Colors.transparent,
            ],
          ),
        ),
        child: const Center(
          child: SizedBox(
            height: 26,
            width: 26,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
