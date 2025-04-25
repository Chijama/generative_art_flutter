import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:generative_art/sunset_api_data.dart';
import 'package:generative_art/models/day_light_data.dart';

/// A widget that fetches and renders a static grid visualization of
/// hours of darkness for a given city's astronomical data.
class DataDrivenHoursOfDark extends StatefulWidget {
  const DataDrivenHoursOfDark({super.key});

  @override
  State<DataDrivenHoursOfDark> createState() => _DataDrivenHoursOfDarkState();
}

class _DataDrivenHoursOfDarkState extends State<DataDrivenHoursOfDark> {
  List<SunlightData>? data;

  /// This class handles data fetching, parsing and local storage per city
  SunsetApiData sunsetApiData =
      SunsetApiData(cityName: '', latitude: 9, longitude: 0, year: 2024);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SunlightData>>(
      future: sunsetApiData.ensureSunDataExists(),
      builder: (context, snapshot) {
        // Show loading spinner while waiting for data
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // Display error if something went wrong
        if (snapshot.hasError) {
          return Center(child: Text('❌ Error: ${snapshot.error}'));
        }

        // Handle empty or null data
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data found.'));
        }

        final data = snapshot.data!;

        // Extract minimum and maximum hours of darkness for mapping
        final darknessValues = data.map((e) => e.hoursOfDarkness).toList();
        final minDark = darknessValues.reduce((a, b) => a < b ? a : b);
        final maxDark = darknessValues.reduce((a, b) => a > b ? a : b);

        return Center(
          child: Column(
            children: [
              // CustomPaint widget renders the grid
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: HoursOfDarkPainter(
                    data: data,
                    maxDark: maxDark,
                    minDark: minDark,
                  ),
                ),
              ),
              // Button to allow clearing the saved local JSON
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
          ),
        );
      },
    );
  }
}

/// CustomPainter that draws a grid of rotated bars where each bar represents
/// the amount of darkness on a specific day.
class HoursOfDarkPainter extends CustomPainter {
  // List of daily sunlight data (each entry represents one day)
  final List<SunlightData> data;

  // Minimum and maximum hours of darkness across the dataset
  final double minDark;
  final double maxDark;

  HoursOfDarkPainter({
    super.repaint,
    required this.data,
    required this.minDark,
    required this.maxDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;

    // Grid layout settings: 23 columns x 16 rows ≈ 368 cells for 365 days
    const cols = 23;
    const rows = 16;
    final days = data.length;

    // Grid dimensions relative to the canvas size
    final gridW = size.width * 0.9; // Use 90% width for grid
    final gridH = size.width * 0.7; // Use 70% width as height for grid
    final cellW = gridW / cols;     // Width of each cell
    final cellH = gridH / cellW;    // Height of each cell based on width
    final margX = (size.width - gridW) * 0.5; // Horizontal margin
    final margY = (size.height - gridH) * 0.5; // Vertical margin

    // Iterate through each day's data and render a visual bar
    for (int i = 0; i < days; i++) {
      final day = data[i];

      // Compute grid coordinates (column-major layout)
      final col = i ~/ rows;
      final row = i % rows;

      // Determine the center of the current cell
      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;

      // Map darkness value to scale factor (width of the bar)
      final scale = _map(day.hoursOfDarkness, minDark, maxDark, 1.0, 3.0);

      // Convert sun azimuth to rotation angle (in radians)
      final theta = day.sunAzimuth != null
          ? (day.sunAzimuth! - 270) * (math.pi / 180)
          : 0.0;

      // Draw a scaled and rotated rectangle
      canvas.save();              // Save current canvas transform state
      canvas.translate(dx, dy);   // Move to center of current cell
      canvas.rotate(theta);       // Rotate by azimuth
      canvas.scale(scale, 1);     // Scale horizontally based on darkness

      // Draw the bar: 2 pixels wide, 30 pixels tall
      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);
      canvas.restore();           // Restore original transform
    }
  }

  /// Maps a value from one range into another
  double _map(double value, double min1, double max1, double min2, double max2) {
    return ((value - min1) / (max1 - min1)) * (max2 - min2) + min2;
  }

  /// Repaint only if needed (false means it's static)
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
