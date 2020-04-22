import 'package:flutter/material.dart';
import 'package:erdbeben/ui/earthquakeMapPage.dart';

class EarthquakeList extends StatefulWidget {
  @override
  _EarthquakeListState createState() => _EarthquakeListState();
}

class _EarthquakeListState extends State<EarthquakeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Text('2.5+'),
        onPressed: () {
          //findQuakes();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

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
}
