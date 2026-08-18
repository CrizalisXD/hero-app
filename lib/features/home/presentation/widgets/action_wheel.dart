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
  CurvedAnimation? _animCurve;
  VoidCallback? _animListener;

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
    _detachAnim();
    _ctrl.dispose();
    super.dispose();
  }

  /// Снимает листенер с предыдущей анимации и освобождает её [CurvedAnimation].
  /// Без этого каждый взмах колеса навешивал НОВЫЙ листенер на тот же
  /// контроллер, а старые оставались жить: после N взмахов один тик прогонял N
  /// замыканий и N вызовов setState — нагрузка росла линейно от числа
  /// взаимодействий и падала только при уходе с экрана.
  void _detachAnim() {
    final listener = _animListener;
    if (listener != null) _anim?.removeListener(listener);
    _animCurve?.dispose();
    _anim = null;
    _animCurve = null;
    _animListener = null;
  }

  /// Оборачивает орб в [Opacity] только когда он действительно полупрозрачный.
  static Widget _maybeFade(double opacity, Widget child) =>
      opacity >= 1.0 ? child : Opacity(opacity: opacity, child: child);

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
    _detachAnim();
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
    _detachAnim();
    _ctrl
      ..duration = Duration(
        milliseconds: (260 + dist / _detent * 90).clamp(220, 700).round(),
      )
      ..reset();
    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    final anim = Tween<double>(begin: from, end: target).animate(curve);
    void listener() => setState(() => _rotation = anim.value);
    anim.addListener(listener);
    _anim = anim;
    _animCurve = curve;
    _animListener = listener;
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
        // Track sweeps well past the window on both ends so the line reads as
        // one long continuous arc curving up-left behind the hero and down off
        // the bottom — not a short stub around the visible nodes.
        const trackHalf = windowHalf + _detent * 1.7;
        // Node zones: the 4 orbs nearest the active zone stay fully SHARP; only
        // an orb that rotates PAST that set blurs/fades out (and the next one
        // fades in). The 4th orb sits at ±1.5·detent, so keep clearHalf above.
        const clearHalf = _detent * 1.7;
        const fadeEnd = _detent * 2.7;

        final children = <Widget>[
          // Track. Геометрия дуги зависит только от размера виджета, но не от
          // поворота колеса, поэтому RepaintBoundary растеризует её один раз.
          // Без него дорогой MaskFilter.blur(9) по 13-пиксельному штриху
          // переписывался в общий слой на каждом кадре прокрутки.
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: false,
                painter: QuestArcPainter(
                  center: c,
                  radius: r,
                  startAngle: -trackHalf,
                  sweepAngle: trackHalf * 2,
                ),
              ),
            ),
          ),
        ];

        for (var i = 0; i < widget.items.length; i++) {
          final item = widget.items[i];
          final angle = _angleOf(i, _rotation);
          final dist = angle.abs();
          if (dist > fadeEnd) continue; // fully outside the visible set

          final x = c.dx + r * math.cos(angle);
          final y = c.dy + r * math.sin(angle);

          // Sharp within the 4-orb clear zone; only orbs rotating past it fade
          // and shrink — so all four visible orbs read crisp and equal.
          final fade = dist <= clearHalf
              ? 1.0
              : (1.0 - (dist - clearHalf) / (fadeEnd - clearHalf))
                  .clamp(0.0, 1.0);
          final opacity = fade;
          final scale = 0.88 + 0.12 * fade;
          const orbSize = 70.0;

          children.add(
            Positioned(
              left: x - 48,
              top: y - orbSize / 2,
              width: 96,
              child: IgnorePointer(
                ignoring: opacity < 0.35,
                // Opacity ниже 1.0 заводит saveLayer (offscreen-проход), а над
                // платформвью это ещё и лишний оверлей — поэтому у чётких орбов
                // (fade == 1.0) слой не создаём вовсе. RepaintBoundary внутри
                // Transform даёт масштабировать уже растеризованный орб на GPU,
                // вместо перерисовки градиента и тени каждый кадр прокрутки.
                child: Transform.scale(
                  scale: scale,
                  child: RepaintBoundary(
                    child: _maybeFade(
                      opacity,
                      QuestMapNode(
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
