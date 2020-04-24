import 'dart:convert';
import 'package:http/http.dart';
import 'package:erdbeben/models/quake.dart';

class Network {

  Future<Quake> getAllQuakes() async {
    var apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_week.geojson";

    final response = await get(Uri.encodeFull(apiUrl));

    if (response.statusCode == 200) {
      print("Quake data: ${response.body}");
      return Quake.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error by getting quakes");
    }
  }
}