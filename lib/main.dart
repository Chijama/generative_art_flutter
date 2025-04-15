import 'package:flutter/material.dart';
import 'package:generative_art/animated_hours_of_dark.dart';
import 'package:generative_art/hours_of_dark.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generative Art Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        // body: HoursOfDark(), //uncomment for normal version
        body: AnimatedHoursOfDark(),
      ),
    );
  }
}
