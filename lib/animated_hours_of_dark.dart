import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// A widget that animates the "Hours of Dark" visualization.
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
    // Initialize the animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8), // Total duration of the animation
    )..forward(); // Start the animation automatically
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose the controller when done
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
                  progress: _animationController.value,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// CustomPainter that draws the animated "Hours of Dark" grid.
class AnimatedHoursOfDarkPainter extends CustomPainter {
  final double progress; // Animation progress from 0 to 1

  AnimatedHoursOfDarkPainter({super.repaint, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Grid configuration
    const cols = 23;
    const rows = 16;
    const days = 365;

    final gridW = size.width * 0.9; // Width of the full grid
    final gridH = size.height * 0.7; // Height of the full grid
    final cellW = gridW / cols; // Width of each cell
    final cellH = gridH / cellW; // Height of each cell
    final margX = (size.width - gridW) * 0.5; // Horizontal margin
    final margY = (size.height - gridH) * 0.5; // Vertical margin

    for (int i = 0; i < days; i++) {
      final col = i ~/ rows; // Column index
      final row = i % rows; // Row index

      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;

      // Generate a "phase" for each day between 0 and π
      final phi = (i / days) * math.pi;

      // Calculate target rotation angle (theta) using sine
      final targetTheta = math.sin(phi) * math.pi * 0.45 * 0.85;

      // Calculate target scaling based on cosine
      final targetScale = (math.cos(phi).abs()) * 2 + 1;

      // Animate rotation and scaling based on progress
      final theta = lerpDouble(0, targetTheta, progress)!;
      final scale = lerpDouble(1, targetScale, progress)!;

      // Save the canvas state before transforming
      canvas.save();

      // Move to the center of the current cell
      canvas.translate(dx, dy);
      // Apply rotation
      canvas.rotate(theta);
      // Apply horizontal scaling
      canvas.scale(scale, 1);

      // Draw a thin vertical bar centered at (0, 0)
      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);

      // Restore the canvas to its previous state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedHoursOfDarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
