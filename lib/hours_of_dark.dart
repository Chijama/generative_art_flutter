import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class HoursOfDark extends StatelessWidget {
  const HoursOfDark({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return CustomPaint(
          size: Size(size, size),
          painter: HoursOfDarkPainter(),
        );
      },
    );
  }
}

class HoursOfDarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const cols = 23;
    const rows = 16;
    const days = 365;

    final gridW = size.width * 0.9;
    final gridH = size.width * 0.7;
    final cellW = gridW / cols;
    final cellH = gridH / cellW;
    final margX = (size.width - gridW) * 0.5;
    final margY = (size.height - gridH) * 0.5;

    for (int i = 0; i < days; i++) {
      final col = i ~/ rows;
      final row = i % rows;
      log("i =$i, col= $col, row = $row");

      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;
      final phi = (i / days) * math.pi;
      final theta = math.sin(phi) * math.pi * 0.45 * 0.85;
      final scale = (math.cos(phi).abs()) * 2 + 1;

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(theta);
      canvas.scale(scale, 1);

      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
