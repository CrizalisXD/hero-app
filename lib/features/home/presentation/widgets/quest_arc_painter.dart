import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Draws a dashed, glowing circular arc — the track of the action wheel.
///
/// The arc is a real circle segment (centre off-screen) so the nodes that sit
/// on it read as a wheel, exactly like the Home reference.
class QuestArcPainter extends CustomPainter {
  const QuestArcPainter({
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.sweepAngle,
    this.color = const Color(0xFFD4AF37),
  });

  /// Circle centre in widget pixel coordinates (off-screen to the right).
  final Offset center;
  final double radius;

  /// Arc bounds in radians.
  final double startAngle;
  final double sweepAngle;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final glow = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final dash = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Dash/gap expressed as arc lengths converted to angular steps.
    final dashA = 9 / radius;
    final gapA = 7 / radius;
    final glowDashA = 14 / radius;
    final glowGapA = 9 / radius;

    _dashedArc(canvas, rect, startAngle, sweepAngle, glow, glowDashA, glowGapA);
    _dashedArc(canvas, rect, startAngle, sweepAngle, dash, dashA, gapA);
  }

  void _dashedArc(
    Canvas canvas,
    Rect rect,
    double start,
    double sweep,
    Paint paint,
    double dashA,
    double gapA,
  ) {
    final end = start + sweep;
    var a = start;
    var draw = true;
    final step = dashA + gapA;
    if (step <= 0) return;
    while (a < end) {
      if (draw) {
        final seg = math.min(dashA, end - a);
        canvas.drawArc(rect, a, seg, false, paint);
      }
      a += draw ? dashA : gapA;
      draw = !draw;
    }
  }

  @override
  bool shouldRepaint(QuestArcPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle ||
      old.color != color;
}
