import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:generative_art/data_driven_hours_of_dark.dart';
import 'package:generative_art/sunset_api_data.dart';
import 'package:generative_art/models/day_light_data.dart';

class AnimatedDataDrivenHoursOfDark extends StatefulWidget {
  const AnimatedDataDrivenHoursOfDark({super.key});

  @override
  State<AnimatedDataDrivenHoursOfDark> createState() =>
      _AnimatedDataDrivenHoursOfDarkState();
}

class _AnimatedDataDrivenHoursOfDarkState
    extends State<AnimatedDataDrivenHoursOfDark>
    with SingleTickerProviderStateMixin {
  List<DaylightData>? data;
  late final AnimationController _controller;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DaylightData>>(
        future: ensureLagosSunDataExists(),
        builder: (context, snapshot) {
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

          final darknessValues = data
              .map(
                (e) => e.hoursOfDarkness,
              )
              .toList();
          final minDark = darknessValues.reduce(
            (value, element) => value < element ? value : element,
          );
          final maxDark = darknessValues.reduce(
            (value, element) => value > element ? value : element,
          );
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
                            progress: _controller.value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await deleteLagosSunDataFile();
                        },
                        child: Text('Delete JSON'),
                      ),
                    ),
                  ],
                );
              });
        });
  }
}

class AnimatedDataDrivenHoursOfDarkPainter extends CustomPainter {
  final List<DaylightData> data;
  final double minDark;
  final double maxDark;
  final double progress;
  AnimatedDataDrivenHoursOfDarkPainter(
      {super.repaint,
      required this.data,
      required this.minDark,
      required this.maxDark,
      required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const cols = 23;
    const rows = 16;
    final days = data.length;

    final gridW = size.width * 0.9;
    final gridH = size.width * 0.7;
    final cellW = gridW / cols;
    final cellH = gridH / cellW;
    final margX = (size.width - gridW) * 0.5;
    final margY = (size.height - gridH) * 0.5;

    for (int i = 0; i < days; i++) {
      final day = data[i];
      final col = i ~/ rows;
      final row = i % rows;

      final dx = margX + col * cellW + cellW * 0.5;
      final dy = margY + row * cellH + cellH * 0.5;

      // Scale based on darkness: 1 (least dark) → 3 (most dark)
      final targetScale = _map(day.hoursOfDarkness, minDark, maxDark, 1.0, 3.0);

      // Angle from sun azimuth if available
      final targetTheta = day.sunAzimuth != null
          ? (day.sunAzimuth! - 270) * (math.pi / 180)
          : 0.0;

      final colProgress = (progress * cols) - col;
      final eased = colProgress.clamp(
        0.0,
        1.0,
      );
      final easedValue =progress;
      final scale = lerpDouble(1.0, targetScale, easedValue)!;
      final theta = lerpDouble(0.0, targetTheta, easedValue)!;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(theta);
      canvas.scale(scale, 1);

      final rect = Rect.fromCenter(center: Offset.zero, width: 2, height: 30);
      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  double _map(
      double value, double min1, double max1, double min2, double max2) {
    return ((value - min1) / (max1 - min1)) * (max2 - min2) + min2;
  }

  @override
  bool shouldRepaint(
          covariant AnimatedDataDrivenHoursOfDarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
