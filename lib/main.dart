import 'package:flutter/material.dart';
import 'package:erdbeben/ui/earthquakePage.dart';

void main() => runApp(
      MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        title: 'Erdbeben',
        home: EarthquakeApp(),
      ),
    );
