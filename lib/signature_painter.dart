import 'sketch.dart';
import 'package:flutter/material.dart';

class SignaturePainter extends CustomPainter {
  SignaturePainter({
    required this.sketches,
  });

  final List<Sketch> sketches;

  @override
  void paint(Canvas canvas, _) {
    for (final sketch in sketches) {
      final points = sketch.points;
      if (points.isEmpty) return;

      final paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round
        ..strokeWidth = sketch.strokeWidth
        ..strokeJoin = StrokeJoin.bevel;

      for (int i = 0; i < points.length - 1; ++i) {
        final startPoint = points[i];
        final endPoint = points[i + 1];
        canvas.drawLine(startPoint, endPoint, paint);
      }

      if (points.length == 1) {
        final singlePoint = points.first;
        final radius = sketch.strokeWidth / 2;
        canvas.drawCircle(
          singlePoint,
          radius,
          paint..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
