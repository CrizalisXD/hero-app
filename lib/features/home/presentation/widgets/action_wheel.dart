import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'quest_arc_painter.dart';
import 'quest_map_node.dart';

/// One spoke of the [ActionWheel].
class WheelItem {
  const WheelItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  /// Attention highlight (gold glow), driven by data — independent of which
  /// item is currently centred.
  final bool isActive;
}

/// Rotatable arc of action orbs, per Home TZ §4.
///
/// Orbs sit on a real circle whose centre is off-screen to the right
/// (`1.16·w, 0.5·h`, radius `0.42·w`). The user grabs and rotates the wheel;
/// it carries momentum, snaps to a detent, and rubber-bands at the ends.
/// Orbs away from the active zone peek (fade + scale down).
class ActionWheel extends StatefulWidget {
  const ActionWheel({super.key, required this.items, this.centerIndexAtStart});

  final List<WheelItem> items;

  /// Which item index (fractional allowed) sits at the active zone (angle 0)
  /// when the wheel first builds. Null keeps the list middle centred.
  final double? centerIndexAtStart;

  // Geometry. Matched to the Home reference image: the circle centre sits to
  // the LEFT (behind the hero) and the visible arc bows out to the RIGHT, so
  // the middle orbs bulge toward the right edge and the ends pull back left.
  // (The TZ §4.1 "centre on the right" wording produces the mirror curve, so
  // we follow the image.) Active zone is angle 0 — the rightmost point.
  //
  // Public: _OrbitBackArc on Home continues the same circle behind the hero,
  // so both must share one geometry.
  static const cxFactor = 0.0; // centre X at the left screen edge
  static const cyFactor = 0.5;
  static const rFactor = 0.85;
  static const detent = 24 * math.pi / 180; // step between orbs

  @override
  State<ActionWheel> createState() => _ActionWheelState();
}

class _ActionWheelState extends State<ActionWheel>
    with SingleTickerProviderStateMixin {
  static const _cxFactor = ActionWheel.cxFactor;
  static const _cyFactor = ActionWheel.cyFactor;
  static const _rFactor = ActionWheel.rFactor;
  static const _detent = ActionWheel.detent;

  late final AnimationController _ctrl;
  Animation<double>? _anim;

  double _rotation = 0; // radians; 0 = middle item centred
  double _dragStartTouchAngle = 0;
  double _rotationAtDragStart = 0;

  double get _maxRotation => (widget.items.length - 1) / 2 * _detent;
  double get _minRotation => -_maxRotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    final ci = widget.centerIndexAtStart;
    if (ci != null) {
      _rotation = (((widget.items.length - 1) / 2 - ci) * _detent)
          .clamp(_minRotation, _maxRotation);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Centre point of the off-screen circle, in local pixels.
  Offset _centre(Size s) => Offset(s.width * _cxFactor, s.height * _cyFactor);
  double _radius(Size s) => s.width * _rFactor;

  /// Angle of item [i] given the current [rotation]. i=0 sits at the top.
  /// Active zone is angle 0 (rightmost). In screen coords y grows downward,
  /// so a negative angle is higher: item 0 gets the most-negative angle.
  double _angleOf(int i, double rotation) {
    final total = (widget.items.length - 1) * _detent;
    return -total / 2 + i * _detent + rotation;
  }

  double _rubber(double r) {
    if (r > _maxRotation) return _maxRotation + (r - _maxRotation) * 0.35;
    if (r < _minRotation) return _minRotation + (r - _minRotation) * 0.35;
    return r;
  }

  void _onPanStart(DragStartDetails d, Size size) {
    _ctrl.stop();
    final c = _centre(size);
    _dragStartTouchAngle =
        math.atan2(d.localPosition.dy - c.dy, d.localPosition.dx - c.dx);
    _rotationAtDragStart = _rotation;
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    final c = _centre(size);
    final a =
        math.atan2(d.localPosition.dy - c.dy, d.localPosition.dx - c.dx);
    var delta = a - _dragStartTouchAngle;
    // Normalise across the ±π wrap.
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    setState(() => _rotation = _rubber(_rotationAtDragStart + delta));
  }

  void _onPanEnd(DragEndDetails d, Size size) {
    // Fling: convert vertical velocity at the active zone into detent steps.
    final r = _radius(size);
    final angularV = d.velocity.pixelsPerSecond.dy / r; // drag down => +rot
    var target = _rotation + angularV * 0.12;
    // Snap to the nearest detent, clamped to the list bounds.
    target = (target / _detent).round() * _detent;
    target = target.clamp(_minRotation, _maxRotation);
    _animateTo(target);
  }

  void _animateTo(double target) {
    final from = _rotation;
    final dist = (target - from).abs();
    _ctrl
      ..duration = Duration(
        milliseconds: (260 + dist / _detent * 90).clamp(220, 700).round(),
      )
      ..reset();
    _anim = Tween<double>(begin: from, end: target).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() => _rotation = _anim!.value));
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final c = _centre(size);
        final r = _radius(size);

        // Arc track spans a bit beyond the first (top) / last (bottom) orbs.
        // Only ~4 orbs are visible at a time. The window is centred on the
        // active zone (angle 0); orbs fade out and stop responding past it,
        // so the wheel always shows a clean set of four-ish big orbs.
        const windowHalf = _detent * 2.0;
        // Track extends a touch past the window to hint "there's more".
        const trackHalf = windowHalf + _detent * 0.9;

        final children = <Widget>[
          // Track.
          Positioned.fill(
            child: CustomPaint(
              painter: QuestArcPainter(
                center: c,
                radius: r,
                startAngle: -trackHalf,
                sweepAngle: trackHalf * 2,
              ),
            ),
          ),
        ];

        for (var i = 0; i < widget.items.length; i++) {
          final item = widget.items[i];
          final angle = _angleOf(i, _rotation);
          final dist = angle.abs();
          if (dist > windowHalf) continue; // outside the 4-orb window

          final x = c.dx + r * math.cos(angle);
          final y = c.dy + r * math.sin(angle);

          // Peek: fade + shrink toward the window edges; big in the middle.
          final t = (dist / windowHalf).clamp(0.0, 1.0);
          final opacity = (1.0 - t * t).clamp(0.0, 1.0);
          final scale = 1.0 - 0.14 * t;
          final orbSize = 70.0 - 10.0 * t; // bigger orbs, per reference

          children.add(
            Positioned(
              left: x - 48,
              top: y - orbSize / 2,
              width: 96,
              child: IgnorePointer(
                ignoring: opacity < 0.35,
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: QuestMapNode(
                      icon: item.icon,
                      label: item.label,
                      color: item.color,
                      badge: item.badge,
                      isActive: item.isActive,
                      size: orbSize,
                      onTap: item.onTap,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onPanStart: (d) => _onPanStart(d, size),
          onPanUpdate: (d) => _onPanUpdate(d, size),
          onPanEnd: (d) => _onPanEnd(d, size),
          child: Stack(clipBehavior: Clip.none, children: children),
        );
      },
    );
  }
}
