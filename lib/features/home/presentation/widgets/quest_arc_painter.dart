import 'package:flutter/material.dart';

/// Draws a smooth, glowing circular arc — the track of the action wheel.
///
/// The arc is a real circle segment (centre off-screen) so the nodes that sit
/// on it read as beads on a single continuous string. A soft SweepGradient
/// fades the line out at both ends, so the track emerges and recedes instead
/// of stopping abruptly — the whole thing reads as one composition rather than
/// a row of separate marks (the old dashed style looked fragmented).
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
    if (radius <= 0 || sweepAngle == 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Three passes for a bright, "energised" track (no gradient — a
    // SweepGradient over a negative start angle blanked half the arc). Round
    // caps soften the ends.
    //   1. wide soft halo   → the track glows into the background
    //   2. solid core line  → full-strength, slightly thicker than before
    //   3. hot inner streak → a near-white highlight so the line reads as lit
    final glow = Paint()
      ..color = color.withValues(alpha: 0.45)
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);

    final line = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final core = Paint()
      ..color = Color.lerp(color, Colors.white, 0.6)!.withValues(alpha: 0.95)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(rect, startAngle, sweepAngle, false, glow);
    canvas.drawArc(rect, startAngle, sweepAngle, false, line);
    canvas.drawArc(rect, startAngle, sweepAngle, false, core);
  }

  @override
  bool shouldRepaint(QuestArcPainter old) =>
      old.center != center ||
      old.radius != radius ||
      old.startAngle != startAngle ||
      old.sweepAngle != sweepAngle ||
      old.color != color;
}
