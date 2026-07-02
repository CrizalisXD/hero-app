import 'package:flutter/material.dart';

/// Рисует пунктирный светящийся путь между точками квест-карты.
///
/// [points] — список позиций (Offset) центров нод в координатах виджета.
/// [color]  — базовый цвет пути.
class QuestPathPainter extends CustomPainter {
  const QuestPathPainter({
    required this.points,
    this.color = const Color(0xFFD4AF37),
    this.progress = 1.0,
  });

  final List<Offset> points;
  final Color color;

  /// 0.0–1.0: доля пути, которую нужно отрисовать (для анимации появления).
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final full = _buildPath();
    // Trim to [progress] of total length for the draw-in animation.
    final path = progress >= 1.0 ? full : _trim(full, progress);

    _drawDashedPath(canvas, path, glowPaint, dashLength: 12, gapLength: 8);
    _drawDashedPath(canvas, path, dashPaint, dashLength: 8, gapLength: 6);
  }

  Path _buildPath() {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, mid.dy, curr.dx, curr.dy);
    }
    return path;
  }

  Path _trim(Path source, double fraction) {
    final metrics = source.computeMetrics().toList();
    final total = metrics.fold<double>(0, (s, m) => s + m.length);
    var remaining = total * fraction.clamp(0.0, 1.0);
    final out = Path();
    for (final m in metrics) {
      if (remaining <= 0) break;
      final take = remaining < m.length ? remaining : m.length;
      out.addPath(m.extractPath(0, take), Offset.zero);
      remaining -= take;
    }
    return out;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final len = draw ? dashLength : gapLength;
        if (draw) {
          final end = (distance + len).clamp(0.0, metric.length).toDouble();
          canvas.drawPath(metric.extractPath(distance, end), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(QuestPathPainter old) =>
      old.points != points || old.progress != progress || old.color != color;
}
