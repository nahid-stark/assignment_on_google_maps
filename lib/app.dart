import 'package:assignment_on_google_maps/presentation/home.dart';
import 'package:flutter/material.dart';

class TrackerApp extends StatefulWidget {
  const TrackerApp({super.key});

  @override
  State<TrackerApp> createState() => _TrackerAppState();
}

class _TrackerAppState extends State<TrackerApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
