import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A simple, static version of the Hours of Dark visualization.
/// 
/// Each bar represents a day of the year.
/// The scale and rotation are mathematically approximated using trigonometric functions
/// to simulate the changes in hours of darkness across the year.
class HoursOfDark extends StatelessWidget {
  const HoursOfDark({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest.shortestSide;
        return Center(
          child: CustomPaint(
            size: Size(size, size),
            painter: HoursOfDarkPainter(),
          ),
        );
      },
    );
  }
}

/// Painter responsible for rendering the Hours of Dark grid.
class HoursOfDarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Define the grid structure
    const cols = 23;
    const rows = 16;
    const days = 365;

    // Calculate the width and height of the entire grid
    final gridW = size.width * 0.9;
    final gridH = size.height * 0.7;

    // Calculate the width and height of each individual cell
    final cellW = gridW / cols;
    final cellH = gridH / cellW; // Cell height maintains proportion

    // Center the grid within the available space
    final margX = (size.width - gridW) * 0.5;
    final margY = (size.height - gridH) * 0.5;

    for (int i = 0; i < days; i++) {
      // Determine the column and row of the current day
      final col = i ~/ rows;
      final row = i % rows;

      // Compute the center position of the current cell
      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;

      // Calculate "phi" as a normalized position across the year (0 → π)
      final phi = (i / days) * math.pi;

      // Determine rotation (theta) based on sine function
      final theta = math.sin(phi) * math.pi * 0.45 * 0.85;

      // Determine scaling based on the cosine function
      final scale = (math.cos(phi).abs()) * 2 + 1;

      // Save the canvas state before transformations
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(theta);
      canvas.scale(scale, 1);

      // Draw the bar centered at (0,0)
      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);

      // Restore the canvas state after drawing
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
