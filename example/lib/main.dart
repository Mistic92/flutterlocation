import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

// add your api key to display a map in flutter
// alternatively display your location in google maps
const String GOOGLE_MAPS_API_KEY = '';

class _MyAppState extends State<MyApp> {
  Map<String, double> _currentLocation = {
    'latitude': -1.0,
    'longitude': -1.0,
    'altitude': -1.0,
    'accuracy': -1.0,
  };

  bool _currentWidget = true;
  bool _canDisplayMap = false;
  Location _location = new Location();

  @override
  initState() {
    _canDisplayMap = GOOGLE_MAPS_API_KEY != '';
    super.initState();
    //updateLocation();
    _location.onLocationChanged.listen((Map<String, double> result) {
      setState(() => _currentLocation = result);
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  updateLocation() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      location = await _location.getLocation;
    } on PlatformException {
      location = null;
    } catch (e) {
      print('Error retrieving Location:\n$e');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() => _currentLocation = location);
  }

  _getStaticMapImage(Map<String, dynamic> location) {
    var path = 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=${location["latitude"]},${location["longitude"]}'
        '&zoom=18&size=640x400&key=$GOOGLE_MAPS_API_KEY';
    return new Image.network(path);
  }

  void _openMap() {
    if (_currentLocation != null) {
      launch(
          'https://www.google.com/maps/@?api=1&map_action=map&query='
          '${_currentLocation['longitude']},${_currentLocation['latitude']}');
    } else {
      print('ERROR: Could not open maps, since there is no location');
    }
  }

  Widget _getLocationRow(String field) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text('$field: '),
        new Text((_currentLocation != null)
            ? '${_currentLocation[field]}'
            : 'not available'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Image image1, image2;
    if (_canDisplayMap) {
      if (_currentWidget) {
        image1 = _getStaticMapImage(_currentLocation);
      } else {
        image2 = _getStaticMapImage(_currentLocation);
      }
      _currentWidget = !_currentWidget;
    }

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(title: new Text('Plugin example app')),
        body: new Center(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              (_canDisplayMap)
                  ? new Stack(children: <Widget>[image1, image2])
                  : new Container(
                      alignment: Alignment.center,
                      height: 100.0,
                      child: new Text(
                        'Could not load map, please set "GOOGLE_MAPS_API_KEY"',
                        textAlign: TextAlign.center,
                      ),
                    ),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: new Column(
                  children: [
                    _getLocationRow('longitude'),
                    _getLocationRow('latitude'),
                    _getLocationRow('accuracy'),
                    _getLocationRow('altitude'),
                    new Padding(padding: const EdgeInsets.only(top: 12.0)),
                  ],
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new RaisedButton(
                    child: new Text('UPDATE LOCATION'),
                    onPressed: () async => await updateLocation(),
                  ),
                  new RaisedButton(
                    child: new Text('OPEN IN MAPS'),
                    onPressed: () => _openMap(),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
