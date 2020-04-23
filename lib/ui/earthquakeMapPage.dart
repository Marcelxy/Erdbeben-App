import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erdbeben/models/quake.dart';
import 'package:erdbeben/network/network.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EarthquakeMap extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EarthquakeMapState();
}

class EarthquakeMapState extends State<EarthquakeMap> with SingleTickerProviderStateMixin {
  double _magnitude;
  Future<Quake> _quakesData;
  List<Marker> _earthquakeList = <Marker>[];
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    _magnitude = 1.0;
    _quakesData = Network().getAllQuakes(_magnitude);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Karte'),
              Tab(text: 'Liste'),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Stack(
              children: <Widget>[
                _buildEarthquakeMap(context),
              ],
            ),
            Text('Hallo'),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  _buildFloatingActionButton() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: const Color(0xFF121212),
      foregroundColor: Colors.white,
      curve: Curves.bounceIn,
      overlayOpacity: 0.0,
      child: Icon(Icons.menu),
      children: [
        SpeedDialChild(
          child: Center(
            child: Text(
              '1.0+',
              style: TextStyle(color: Colors.green),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          onTap: () => _findQuakes(1.0),
        ),
        SpeedDialChild(
          child: Center(
            child: Text(
              '2.5+',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          onTap: () => _findQuakes(2.5),
        ),
        SpeedDialChild(
          child: Center(
            child: Text(
              '4.5+',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          onTap: () => _findQuakes(4.5),
        ),
      ],
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
        mapToolbarEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: CameraPosition(target: LatLng(52.519735, 13.4046413)), // Berlin
        markers: Set<Marker>.of(_earthquakeList),
      ),
    );
  }

  void _findQuakes(double magnitude) {
    setState(() {
      _earthquakeList.clear();
      _handleResponse(magnitude);
    });
  }

  /// Setzt alle Erdbeben Marker die dann auf der Google Map angezeigt werden.
  void _handleResponse(double magnitude) {
    setState(
      () {
        _quakesData.then(
          (quakes) => [
            quakes.features.forEach(
              (quake) => [
                if (quake.properties.mag >= magnitude)
                  {
                    _earthquakeList.add(Marker(
                        markerId: MarkerId(quake.id),
                        infoWindow: InfoWindow(title: quake.properties.mag.toString(), snippet: quake.properties.place),
                        icon: _setMarkerColor(quake.properties.mag),
                        position: LatLng(quake.geometry.coordinates[1], quake.geometry.coordinates[0]),
                        onTap: () {}))
                  }
              ],
            ),
          ],
        );
      },
    );
  }

  BitmapDescriptor _setMarkerColor(double magnitude) {
    if (magnitude >= 0.0 && magnitude < 2.5) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    } else if (magnitude >= 2.5 && magnitude < 4.5) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    } else {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
  }
}
