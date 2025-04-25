import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:generative_art/models/astronomy_model.dart';
import 'package:generative_art/models/day_light_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// A service class for fetching and caching astronomy data
/// (e.g. sunrise, sunset, darkness hours) for a specific city and year.
class SunsetApiData {
  final double longitude;
  final double latitude;
  final String cityName;
  final int year;
  SunsetApiData({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.year,
  });

  /// API key loaded from .env file
  final apiKey = dotenv.get('API_KEY');

  /// Dynamic file name based on city
  String get fileName => '${cityName}_sun_data_$year.json';

  /// Ensures sun data is fetched and cached for this city.
  /// If the file already exists and has content, it is read and parsed.
  Future<List<SunlightData>> ensureSunDataExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}\\$fileName');
    List<SunlightData> data = [];

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        log('📂 File already exists and has content. Skipping fetch.');

        final jsonList = jsonDecode(content) as List;
        final astroData = <AstronomyData>[];

        // Parse each JSON entry safely
        for (final e in jsonList) {
          try {
            astroData.add(AstronomyData.fromJson(e));
          } catch (err, stacktrace) {
            log('❌ Error converting entry: $e',
                error: err, stackTrace: stacktrace);
          }
        }

        log('📦 First entry: ${jsonList.first}');

        // Convert to DaylightData
        final daylightData = astroData.map((e) {
          final daylightMinutes = e.sunset.difference(e.sunrise).inMinutes;
          final darknessHours = (1440 - daylightMinutes) / 60.0;
          return SunlightData(
            date: e.date,
            hoursOfDarkness: darknessHours,
            sunAzimuth: e.sunAzimuth,
          );
        }).toList();

        data = daylightData;
      }
    } else {
      // File does not exist — fetch from API
      log('📡 Fetching new $cityName sun data...');
      await fetchAstronomyData();
      data = await readSavedJson(fileName);
    }

    return data;
  }

  /// Fetches astronomy data from the API for the full year and saves it.
  Future<List<AstronomyData>> fetchAstronomyData() async {
    final List<AstronomyData> data = [];

    final totalDays = DateTime(year + 1).difference(DateTime(year)).inDays;

    for (int i = 0; i < totalDays; i++) {
      final date = DateTime(year, 1, 1).add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final url = Uri.parse(
        'https://api.ipgeolocation.io/astronomy?apiKey=$apiKey&lat=$latitude&long=$longitude&date=$dateStr',
      );

      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          log(result.toString());

          final astro = AstronomyData.fromJson(result);
          data.add(astro);
        } else {
          print('⚠️ Failed on $dateStr: ${response.statusCode}');
        }

        // Respect rate limits
        await Future.delayed(Duration(milliseconds: 200));
      } catch (e, stacktrace) {
        print('❌ Error on $dateStr: $e, stacktrace: $stacktrace');
      }
    }

    // Save result to local JSON file
    await saveAstronomyDataToJson(data);

    return data;
  }

  /// Writes a list of [AstronomyData] entries to the local JSON file.
  Future<void> saveAstronomyDataToJson(List<AstronomyData> data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}\\$fileName');

      log('📁 Saving to ${file.path}');

      final jsonList = data.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList), flush: true);

      log('✅ File saved!');
    } catch (e, stacktrace) {
      log('❌ Error saving JSON', error: e, stackTrace: stacktrace);
    }
  }

  /// Reads saved JSON and converts it to a list of [SunlightData]
  Future<List<SunlightData>> readSavedJson(String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}\\$filename');

      if (!await file.exists()) {
        throw Exception('❌ File not found: ${file.path}');
      }

      final content = await file.readAsString();
      if (content.trim().isEmpty) {
        throw Exception('⚠️ File is empty: ${file.path}');
      }

      final data = jsonDecode(content);
      final astroData = (data as List<dynamic>)
          .map((e) => AstronomyData.fromJson(e as Map<String, dynamic>))
          .toList();

      return astroData.map((e) {
        final daylightMinutes = e.sunset.difference(e.sunrise).inMinutes;
        final darknessHours = (1440 - daylightMinutes) / 60.0;
        return SunlightData(
          date: e.date,
          hoursOfDarkness: darknessHours,
          sunAzimuth: e.sunAzimuth,
        );
      }).toList();
    } catch (e, stacktrace) {
      log('❌ Error reading or parsing saved JSON',
          error: e, stackTrace: stacktrace);
      return [];
    }
  }

  /// Deletes the local cached JSON file if it exists.
  Future<void> deleteLagosSunDataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}\\$fileName');

    if (await file.exists()) {
      await file.delete();
      debugPrint('🗑️ File deleted: ${file.path}');
    } else {
      print('⚠️ File not found: ${file.path}');
    }
  }
}
