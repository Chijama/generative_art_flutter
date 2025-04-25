class SunlightData {
  final DateTime date;
  final double hoursOfDarkness;
  final double? sunAzimuth;

  SunlightData({
    required this.date,
    required this.hoursOfDarkness,
    this.sunAzimuth,
  });

  factory SunlightData.fromJson(Map<String, dynamic> json) {
    return SunlightData(
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
