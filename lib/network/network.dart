import 'dart:convert';
import 'package:http/http.dart';
import 'package:erdbeben/models/quake.dart';

class Network {

  Future<Quake> getAllQuakes(double magnitude) async {
    var apiUrl;
    if (magnitude == 1.0) {
      apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_week.geojson";
    } else if (magnitude == 2.5) {
      apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_week.geojson";
    } else if (magnitude == 4.5) {
      apiUrl = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_week.geojson";
    }

    final response = await get(Uri.encodeFull(apiUrl));

    if (response.statusCode == 200) {
      //print("Quake data: ${response.body}");
      return Quake.fromJson(json.decode(response.body));
    } else {
      throw Exception("Error by getting quakes");
    }
  }
}