import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedHoursOfDark extends StatefulWidget {
  const AnimatedHoursOfDark({super.key});

  @override
  State<AnimatedHoursOfDark> createState() => _AnimatedHoursOfDarkState();
}

class _AnimatedHoursOfDarkState extends State<AnimatedHoursOfDark>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
      
        final size = constraints.biggest.shortestSide;

        return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Align(
                alignment: Alignment.center,
                child: CustomPaint(
                  size: Size(size, size),
                
                  painter: AnimatedHoursOfDarkPainter(
                      progress: _animationController.value),
                ),
              );
            });
      },
    );
  }
}

class AnimatedHoursOfDarkPainter extends CustomPainter {
  final double progress;

  AnimatedHoursOfDarkPainter({super.repaint, required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const cols = 23;
    const rows = 16;
    const days = 365;

    final gridW = size.width * 0.9;
    final gridH = size.height * 0.7;
    final cellW = gridW / cols;
    final cellH = gridH / cellW;
    final margX = (size.width - gridW) * 0.5;
    final margY = (size.height - gridH) * 0.5;

    for (int i = 0; i < days; i++) {
      final col = i ~/ rows;
      final row = i % rows;

      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;
      final phi = (i / days) * math.pi;
      final targetTheta = math.sin(phi) * math.pi * 0.45 * 0.85;
      final targetScale = (math.cos(phi).abs()) * 2 + 1;

      // Animate column by column
      final colProgress = (progress * cols) - col;
      final eased = colProgress.clamp(0.0, 1.0);
      final easedValue = Curves.easeInOut.transform(eased);

      final theta = lerpDouble(0, targetTheta, easedValue)!;
      final scale = lerpDouble(1, targetScale, easedValue)!;
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
  bool shouldRepaint(covariant AnimatedHoursOfDarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
