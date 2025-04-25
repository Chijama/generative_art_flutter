import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:generative_art/sunset_api_data.dart';
import 'package:generative_art/models/day_light_data.dart';

/// A widget that fetches and animates a visualization of the hours of darkness
/// for a given city's 2024 astronomical data.
class AnimatedDataDrivenHoursOfDark extends StatefulWidget {
  const AnimatedDataDrivenHoursOfDark({super.key});

  @override
  State<AnimatedDataDrivenHoursOfDark> createState() =>
      _AnimatedDataDrivenHoursOfDarkState();
}

class _AnimatedDataDrivenHoursOfDarkState
    extends State<AnimatedDataDrivenHoursOfDark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Data provider for astronomical sun data.
  final SunsetApiData sunsetApiData = SunsetApiData(
    cityName: 'lagos',
    latitude: 9,
    longitude: 0,
    year: 2024,
  );

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SunlightData>>(
      future: sunsetApiData.ensureSunDataExists(),
      builder: (context, snapshot) {
        // Show loading spinner while fetching data
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('❌ Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found.'));
        }

        final data = snapshot.data!;

        // Find min and max values for darkness to normalize scale later
        final darknessValues = data.map((e) => e.hoursOfDarkness).toList();
        final minDark = darknessValues.reduce(math.min);
        final maxDark = darknessValues.reduce(math.max);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: AnimatedDataDrivenHoursOfDarkPainter(
                      data: data,
                      maxDark: maxDark,
                      minDark: minDark,
                      progress: _controller.value,
                    ),
                  ),
                ),
                // Display city name below chart
                Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Text(
                    sunsetApiData.cityName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Button to delete cached JSON file
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await sunsetApiData.deleteLagosSunDataFile();
                    },
                    child: Text('Delete JSON'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Painter that animates darkness bars based on city sun data.
class AnimatedDataDrivenHoursOfDarkPainter extends CustomPainter {
  // Data for each day (e.g. darkness hours, sun azimuth)
  final List<SunlightData> data;

  // The minimum and maximum darkness values in the dataset
  final double minDark;
  final double maxDark;

  // Animation progress (0.0 → 1.0)
  final double progress;

  AnimatedDataDrivenHoursOfDarkPainter({
    super.repaint,
    required this.data,
    required this.minDark,
    required this.maxDark,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Grid configuration: 23 columns × 16 rows = 368 (enough for a year)
    const cols = 23;
    const rows = 16;
    final days = data.length;

    // Calculate grid dimensions based on canvas size
    final gridW = size.width * 0.9;      // Width = 90% of canvas
    final gridH = size.width * 0.7;      // Height = 70% of canvas (for balance)
    final cellW = gridW / cols;          // Width of each cell
    final cellH = gridH / cellW;         // Height is based on cell width
    final margX = (size.width - gridW) * 0.5; // Horizontal margin
    final margY = (size.height - gridH) * 0.5; // Vertical margin

    // Loop through all days and draw a rectangle for each
    for (int i = 0; i < days; i++) {
      final day = data[i];

      // Determine grid position
      final col = i ~/ rows;
      final row = i % rows;

      // Center point for each cell
      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;

      // Target scale based on hours of darkness (1 = least dark, 3 = most)
      final targetScale = _map(day.hoursOfDarkness, minDark, maxDark, 1.0, 3.0);

      // Optional rotation based on sun azimuth (angle at sunset)
      final targetTheta = day.sunAzimuth != null
          ? (day.sunAzimuth! - 270) * (math.pi / 180) // normalize angle
          : 0.0;

      // Interpolate scale and rotation using animation progress
      final scale = lerpDouble(1.0, targetScale, progress)!;
      final theta = lerpDouble(0.0, targetTheta, progress)!;

      // Save current canvas state
      canvas.save();

      // Apply transformations
      canvas.translate(dx, dy);   // Move to cell center
      canvas.rotate(theta);       // Rotate based on azimuth
      canvas.scale(scale, 1);     // Scale width (darkness)

      // Draw the vertical rectangle centered at origin
      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);

      // Restore canvas to original state
      canvas.restore();
    }
  }

  /// Maps a value from one range into another
  double _map(
    double value,
    double min1, double max1,
    double min2, double max2,
  ) {
    return ((value - min1) / (max1 - min1)) * (max2 - min2) + min2;
  }

  /// Repaint only when the animation progress changes
  @override
  bool shouldRepaint(
          covariant AnimatedDataDrivenHoursOfDarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
