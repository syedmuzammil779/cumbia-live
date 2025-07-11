import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LinePainter extends CustomPainter {
  final int hour;

  LinePainter({required this.hour});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF30B0C7)
      ..strokeWidth = 3.w
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final angle = ((hour % 12) / 12) * 2 * pi;
    final radius = hour <= 12 ? 120.0 : 75.0;

    final endX = center.dx + radius * cos(angle);
    final endY = center.dy + radius * sin(angle);

    final end = Offset(endX, endY);

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.hour != hour;
  }
}

class LinePainterMinutes extends CustomPainter {
  final int minute;

  LinePainterMinutes({required this.minute});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF30B0C7)
      ..strokeWidth = 3.w
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final angle = ((minute % 30) / 30) * 2 * pi;
    final radius = minute < 30 ? 120.0 : 75.0;

    final endX = center.dx + radius * cos(angle);
    final endY = center.dy + radius * sin(angle);

    final end = Offset(endX, endY);

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainterMinutes oldDelegate) {
    return oldDelegate.minute != minute;
  }
}
