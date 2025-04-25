import 'package:intl/intl.dart';

class AstronomyData {
  final Location location;
  final DateTime date;
  final DateTime currentTime;
  final DateTime sunrise;
  final DateTime sunset;
  final String sunStatus;
  final DateTime solarNoon;
  final Duration dayLength;
  final double sunAltitude;
  final double sunDistance;
  final double sunAzimuth;
  final DateTime moonrise;
  final DateTime moonset;
  final String moonStatus;
  final double moonAltitude;
  final double moonDistance;
  final double moonAzimuth;
  final double moonParallacticAngle;
  final String moonPhase;
  final double moonIlluminationPercentage;
  final double moonAngle;

  AstronomyData({
    required this.location,
    required this.date,
    required this.currentTime,
    required this.sunrise,
    required this.sunset,
    required this.sunStatus,
    required this.solarNoon,
    required this.dayLength,
    required this.sunAltitude,
    required this.sunDistance,
    required this.sunAzimuth,
    required this.moonrise,
    required this.moonset,
    required this.moonStatus,
    required this.moonAltitude,
    required this.moonDistance,
    required this.moonAzimuth,
    required this.moonParallacticAngle,
    required this.moonPhase,
    required this.moonIlluminationPercentage,
    required this.moonAngle,
  });

  factory AstronomyData.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    final DateFormat timeFormat = DateFormat('HH:mm');

    DateTime parseTime(String? t) {
      if (t == null || t.trim() == '-:-') {
        return date; // Or return a fallback/default value
      }

      try {
        return timeFormat.parse(t).copyWith(
              year: date.year,
              month: date.month,
              day: date.day,
            );
      } catch (_) {
        return date;
      }
    }

    num parseNum(dynamic value) => num.tryParse(value.toString()) ?? 0;

    return AstronomyData(
      location: Location.fromJson(json['location']),
      date: date,
currentTime: parseDateTime(json['current_time'], date),
      sunrise: parseTime(json['sunrise']),
      sunset: parseTime(json['sunset']),
      sunStatus: json['sun_status'],
      solarNoon: parseTime(json['solar_noon']),
      dayLength: _parseDuration(json['day_length']),
      sunAltitude: parseNum(json['sun_altitude']).toDouble(),
      sunDistance: parseNum(json['sun_distance']).toDouble(),
      sunAzimuth: parseNum(json['sun_azimuth']).toDouble(),
      moonrise: parseTime(json['moonrise']),
      moonset: parseTime(json['moonset']),
      moonStatus: json['moon_status'],
      moonAltitude: parseNum(json['moon_altitude']).toDouble(),
      moonDistance: parseNum(json['moon_distance']).toDouble(),
      moonAzimuth: parseNum(json['moon_azimuth']).toDouble(),
      moonParallacticAngle: parseNum(json['moon_parallactic_angle']).toDouble(),
      moonPhase: json['moon_phase'],
      moonIlluminationPercentage:
          parseNum(json['moon_illumination_percentage']).toDouble(),
      moonAngle: parseNum(json['moon_angle']).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'date': date.toIso8601String(),
      'current_time': currentTime.toIso8601String(),
      'sunrise': _formatTime(sunrise),
      'sunset': _formatTime(sunset),
      'sun_status': sunStatus,
      'solar_noon': _formatTime(solarNoon),
      'day_length': _formatDuration(dayLength),
      'sun_altitude': sunAltitude,
      'sun_distance': sunDistance,
      'sun_azimuth': sunAzimuth,
      'moonrise': _formatTime(moonrise),
      'moonset': _formatTime(moonset),
      'moon_status': moonStatus,
      'moon_altitude': moonAltitude,
      'moon_distance': moonDistance,
      'moon_azimuth': moonAzimuth,
      'moon_parallactic_angle': moonParallacticAngle,
      'moon_phase': moonPhase,
      'moon_illumination_percentage': moonIlluminationPercentage,
      'moon_angle': moonAngle,
    };
  }

  String _formatTime(DateTime dt) => DateFormat('HH:mm').format(dt);

  String _formatDuration(Duration d) {
    return '${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
static DateTime parseDateTime(dynamic raw, DateTime baseDate) {
  final str = raw.toString();
  if (str.contains('T')) return DateTime.parse(str);
  return DateFormat('HH:mm:ss.SSS').parse(str).copyWith(
    year: baseDate.year,
    month: baseDate.month,
    day: baseDate.day,
  );
}

  static Duration _parseDuration(String timeString) {
    final parts = timeString.split(':').map(int.parse).toList();

    final hours = parts[0];
    final minutes = parts.length > 1 ? parts[1] : 0;
    final seconds = parts.length > 2 ? parts[2] : 0;

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (num.tryParse(json['latitude']) ?? 0).toDouble(),
      longitude: (num.tryParse(json['longitude']) ?? 0).toDouble(),
    );
  }
}
