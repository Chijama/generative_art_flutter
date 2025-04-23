class DaylightData {
  final DateTime date;
  final double hoursOfDarkness;
  final double? sunAzimuth;

  DaylightData({
    required this.date,
    required this.hoursOfDarkness,
    this.sunAzimuth,
  });

  factory DaylightData.fromJson(Map<String, dynamic> json) {
    return DaylightData(
      date: DateTime.parse(json['date']),
      hoursOfDarkness: (json['hoursOfDarkness'] as num).toDouble(),
      sunAzimuth: json['sunAzimuth'] != null
          ? (json['sunAzimuth'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'hoursOfDarkness': hoursOfDarkness,
      'sunAzimuth': sunAzimuth,
    };
  }
}
