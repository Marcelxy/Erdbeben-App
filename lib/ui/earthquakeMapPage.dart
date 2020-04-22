import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erdbeben/models/quake.dart';
import 'package:erdbeben/network/network.dart';
import 'package:erdbeben/ui/earthquakeListPage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EarthquakeMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EarthquakeMapState();
}

class EarthquakeMapState extends State<EarthquakeMap> {
  Future<Quake> _quakesData;
  List<Marker> _earthquakeList = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _quakesData = Network().getAllQuakes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Text('2.5+'),
        onPressed: () {
          findQuakes();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
      body: Stack(
        children: <Widget>[
          _buildEarthquakeMap(context),
        ],
      ),
    );
  }

  /// Erstellt die Google Map und legt die Startposition der Kamera auf Berlin fest.
  _buildEarthquakeMap(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: GoogleMap(
        mapType: MapType.hybrid,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: CameraPosition(target: LatLng(52.519735, 13.4046413)),   // Berlin
        markers: Set<Marker>.of(_earthquakeList),
      ),
    );
  }

  /// Erstellt die untere Navigationsleiste mit Karte und Liste Buttons.
  _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EarthquakeMap()));
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.public),
                Text(
                  'Karte',
                  style: TextStyle(height: 1.3),
                ),
              ],
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => EarthquakeList()));
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.storage),
                Text(
                  'Liste',
                  style: TextStyle(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  findQuakes() {
    setState(() {
      _earthquakeList.clear();
      _handleResponse();
    });
  }

  /// Setzt alle Erdbeben Marker die dann auf der Google Map angezeigt werden.
  void _handleResponse() {
    setState(
      () {
        _quakesData.then(
          (quakes) => [
            quakes.features.forEach(
              (quake) => [
                _earthquakeList.add(Marker(
                    markerId: MarkerId(quake.id),
                    infoWindow: InfoWindow(title: quake.properties.mag.toString(), snippet: quake.properties.place),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
                    position: LatLng(quake.geometry.coordinates[1], quake.geometry.coordinates[0]),
                    onTap: () {}))
              ],
            ),
          ],
        );
      },
    );
  }
}
