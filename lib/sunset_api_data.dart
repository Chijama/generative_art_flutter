import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:generative_art/models/astronomy_model.dart';
import 'package:generative_art/models/day_light_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

final apiKey = dotenv.get('API_KEY');
final fileName = 'lagos_sun_data_2024.json';

Future<List<DaylightData>> ensureLagosSunDataExists() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}\\$fileName');
  List<DaylightData> data = [];
  if (await file.exists()) {
    final content = await file.readAsString();
    if (content.trim().isNotEmpty) {
      log('📂 File already exists and has content. Skipping fetch.');
      final jsonList = jsonDecode(content) as List;
      final astroData = <AstronomyData>[];
      for (final e in jsonList) {
        try {
          astroData.add(AstronomyData.fromJson(e));
        } catch (err, stacktrace) {
          log('❌ Error converting entry: $e',
              error: err, stackTrace: stacktrace);
        }
      }
      log('📦 First entry: ${jsonList.first}');

      final daylightData = astroData.map((e) {
        final sunrise = e.sunrise;
        final sunset = e.sunset;

        final daylightMinutes = sunset.difference(sunrise).inMinutes;
        final darknessMinutes = 1440 - daylightMinutes;
        final darknessHours = darknessMinutes / 60.0;

        final azimuth = e.sunAzimuth;
        return DaylightData(
            date: e.date, hoursOfDarkness: darknessHours, sunAzimuth: azimuth);
      }).toList();
      data = daylightData ?? [];
    }
  } else {
    log('📡 Fetching new Lagos sun data...');
    await fetchAstronomyData();
    data = await readSavedJson(fileName);
  }
  return data;
}

Future<List<AstronomyData>> fetchAstronomyData() async {
  final List<AstronomyData> data = [];
  const latitude = 6.465422;
  const longitude = 3.406448;
  const year = 2024;
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

      await Future.delayed(Duration(milliseconds: 200)); // Respect rate limits
    } catch (e, stacktrace) {
      print('❌ Error on $dateStr: $e, stacktrace: $stacktrace');
    }
  }
  await saveAstronomyDataToJson(data);

  return data;
}

Future<void> saveAstronomyDataToJson(List<AstronomyData> data) async {
  try {
    final dir = await getApplicationDocumentsDirectory();

    final file = File('${dir.path}\\$fileName');
    log('📁 Saving to ${file.path}');

    final jsonList = data.map((e) => e.toJson()).toList();
    await file.writeAsString(json.encode(jsonList), flush: true);

    log('✅ File saved!');
  } catch (e, stacktrace) {
    log('', error: e, stackTrace: stacktrace);
  }
}

Future<List<DaylightData>> readSavedJson(String filename) async {
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
    final astroData = (data as List<dynamic>).map((e) {
      return AstronomyData.fromJson(e as Map<String, dynamic>);
    }).toList();

    final daylightData = astroData.map((e) {
      final daylightMinutes = e.sunset.difference(e.sunrise).inMinutes;
      final darknessHours = (1440 - daylightMinutes) / 60.0;

      return DaylightData(
        date: e.date,
        hoursOfDarkness: darknessHours,
        sunAzimuth: e.sunAzimuth,
      );
    }).toList();

    return daylightData;
  } catch (e, stacktrace) {
    log('❌ Error reading or parsing saved JSON',
        error: e, stackTrace: stacktrace);
    return []; // Return an empty list to keep app alive
  }
}

Future<void> deleteLagosSunDataFile() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}\\$fileName');

  if (await file.exists()) {
    await file.delete();
    print('🗑️ File deleted: ${file.path}');
  } else {
    print('⚠️ File not found: ${file.path}');
  }
}
