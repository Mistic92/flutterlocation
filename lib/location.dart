import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';

class Location {
  static const MethodChannel _channel = const MethodChannel('lyokone/location');
  static const EventChannel _stream =
      const EventChannel('lyokone/locationstream');

  Stream<Map<String, double>> _onLocationChanged;

  Future<Map<String, double>> get getLocation async {
    return  Map.from<String, double>(await _channel.invokeMethod('getLocation'));
  }

  Stream<Map<String, double>> get onLocationChanged {
    if (_onLocationChanged == null) {
      _onLocationChanged = _stream
          .receiveBroadcastStream()
          .map((dynamic) => Map.from<String, double>(dynamic));
    }
    return _onLocationChanged;
  }
}
