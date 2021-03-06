import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erdbeben/models/quake.dart';
import 'package:erdbeben/network/network.dart';
import 'package:erdbeben/models/periodOfTimeChoices.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EarthquakeApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new EarthquakeAppState();
}

class EarthquakeAppState extends State<EarthquakeApp> with SingleTickerProviderStateMixin {
  String _timeFilter;
  double _magnitudeFilter;
  Future<Quake> _quakesData;
  List<Marker> _earthquakeList;
  Completer<GoogleMapController> _controller = Completer();

  @override
  void initState() {
    super.initState();
    _timeFilter = 'day';
    _magnitudeFilter = 1.0;
    _earthquakeList = <Marker>[];
    _quakesData = Network().getAllQuakes();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '$_magnitudeFilter+ ${_getTimeFilter()}',
            style: TextStyle(fontSize: 17.0),
          ),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: _choiceAction,
              itemBuilder: (BuildContext context) {
                return PeriodOfTimeChoices.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _quakesData = Network().getAllQuakes();
              });
            },
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(Icons.public),
                    ),
                    Text(
                      'Karte',
                      style: TextStyle(fontSize: 16.5),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Icon(Icons.menu),
                  ),
                  Text(
                    'Liste',
                    style: TextStyle(fontSize: 16.5),
                  ),
                ],
              ),
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
            _buildEarthquakeList(context),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  ////////////////////////////////////////////
  ///      Allgemeine Funktionalitäten
  ////////////////////////////////////////////

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
          onTap: () => _findQuakes(1.0, _timeFilter),
        ),
        SpeedDialChild(
          child: Center(
            child: Text(
              '2.5+',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          onTap: () => _findQuakes(2.5, _timeFilter),
        ),
        SpeedDialChild(
          child: Center(
            child: Text(
              '4.5+',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          backgroundColor: const Color(0xFF121212),
          onTap: () => _findQuakes(4.5, _timeFilter),
        ),
      ],
    );
  }

  void _findQuakes(double magnitudeFilter, String timeFilter) {
    setState(() {
      _magnitudeFilter = magnitudeFilter;
      _timeFilter = timeFilter;
      _earthquakeList.clear();
      _handleResponse();
    });
  }

  /// Der Parameter millisecondsSince1970 wird von jedem Erdbeben aus den JSON Daten ausgelesen
  /// um zu bestimmen wielange das Erdbeben her ist. Danach wird bestimmt, ob das Erdbeben unter einer
  /// Stunde, unter einem Tag oder unter 7 Tagen her ist. Alle Angaben in Millisekunden.
  bool _calculatePastTime(int millisecondsSince1970) {
    int pastTime = DateTime.now().millisecondsSinceEpoch - millisecondsSince1970;
    // Eine Stunde hat 3.600.000 Millisekunden
    if (_timeFilter == 'hour' && pastTime < 3600000) {
      return true;
    }
    // Ein Tag hat 86.400.000 Millisekunden
    else if (_timeFilter == 'day' && pastTime < 86400000) {
      return true;
    }
    // Eine Woche hat 604.800.000 Millisekunden
    else if (_timeFilter == 'week' && pastTime < 604800000) {
      return true;
    }
    return false;
  }

  // TODO kommentieren!!!
  String _getPastTimeString(int millisecondsSince1970) {
    int pastTime = DateTime.now().millisecondsSinceEpoch - millisecondsSince1970;
    double minutes = pastTime / 60000; // Eine Minute hat 60.000 Millisekunden
    if (minutes.round() >= 60) {
      double hours = pastTime / 3600000; // Eine Stunde hat 3.600.000 Millisekunden
      if (hours.round() >= 24) {
        double days = pastTime / 86400000; // Ein Tag hat 86.400.000 Millisekunden
        return days.round() > 1 ? 'Vor ${days.round()} Tagen' : 'Vor ${days.round()} Tag';
      } else {
        return hours.round() > 1 ? 'Vor ${hours.round()} Stunden' : 'Vor ${hours.round()} Stunde';
      }
    } else {
      return minutes.round() > 1 ? 'Vor ${minutes.round()} Minuten' : 'Vor ${minutes.round()} Minute';
    }
  }

  void _choiceAction(String choice) {
    if (choice == PeriodOfTimeChoices.hour) {
      _timeFilter = 'hour';
    } else if (choice == PeriodOfTimeChoices.day) {
      _timeFilter = 'day';
    } else if (choice == PeriodOfTimeChoices.week) {
      _timeFilter = 'week';
    }
    _findQuakes(_magnitudeFilter, _timeFilter);
  }

  String _getTimeFilter() {
    if (_timeFilter == 'hour') {
      return PeriodOfTimeChoices.hour;
    } else if (_timeFilter == 'day') {
      return PeriodOfTimeChoices.day;
    } else if (_timeFilter == 'week') {
      return PeriodOfTimeChoices.week;
    }
    return '';
  }

  ////////////////////////////////////////////
  ///         Erdbeben Karte Seite
  ////////////////////////////////////////////

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
        initialCameraPosition: CameraPosition(target: LatLng(52.519735, 13.4046413)), // Berlin (zirka Fernsehrturm)
        markers: Set<Marker>.of(_earthquakeList),
      ),
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

  /// Setzt alle Erdbeben Marker die dann auf der Google Map angezeigt werden.
  void _handleResponse() {
    setState(
      () {
        _quakesData.then(
          (quakes) => [
            quakes.features.forEach(
              (quake) => [
                if (quake.properties.mag >= _magnitudeFilter)
                  {
                    if (_calculatePastTime(quake.properties.time))
                      {
                        _earthquakeList.add(Marker(
                            markerId: MarkerId(quake.id),
                            infoWindow: InfoWindow(
                                title:
                                    '${quake.properties.mag.toString()} ${_getPastTimeString(quake.properties.time)}',
                                snippet: quake.properties.place),
                            icon: _setMarkerColor(quake.properties.mag),
                            position: LatLng(
                                quake.geometry.coordinates[1].toDouble(), quake.geometry.coordinates[0].toDouble()),
                            onTap: () {}))
                      }
                  }
              ],
            ),
          ],
        );
      },
    );
  }

  ////////////////////////////////////////////
  ///         Erdbeben Liste Seite
  ////////////////////////////////////////////
  _buildEarthquakeList(BuildContext context) {
    return Center(
      child: Container(
        child: FutureBuilder(
          future: _quakesData,
          builder: (context, AsyncSnapshot<Quake> snapshot) {
            if (snapshot.hasData) {
              List<Features> allQuakes = <Features>[];
              for (int i = 0; i < snapshot.data.features.length; i++) {
                if (snapshot.data.features[i].properties.mag >= _magnitudeFilter) {
                  if (_calculatePastTime(snapshot.data.features[i].properties.time)) {
                    allQuakes.add(snapshot.data.features[i]);
                  }
                }
              }
              return _createEarthquakeListView(allQuakes, context);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget _createEarthquakeListView(List<Features> earthquakeData, BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: earthquakeData.length,
        itemBuilder: (context, int index) {
          return Column(
            children: <Widget>[
              Divider(height: 5.0),
              ListTile(
                isThreeLine: true,
                title: Text('${earthquakeData[index].properties.place}'),
                subtitle: Text(
                  '${_getPastTimeString(earthquakeData[index].properties.time)}\nTiefe: ${earthquakeData[index].geometry.coordinates[2].toStringAsFixed(2)} km',
                  style: TextStyle(height: 1.6),
                ),
                leading: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 25,
                      child: Text(
                        '${earthquakeData[index].properties.mag}',
                        style: TextStyle(
                          color: _setMagnitudeTextColor(earthquakeData[index].properties.mag),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _setMagnitudeTextColor(double magnitude) {
    if (magnitude >= 0.0 && magnitude < 2.5) {
      return Colors.green;
    } else if (magnitude >= 2.5 && magnitude < 4.5) {
      return Colors.yellow;
    } else {
      return Colors.orange;
    }
  }
}
