import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationManager with WidgetsBindingObserver {
  static const String deniedForeverKey = 'denied_forever';

  final SharedPreferences sharedPreferences;

  // ignore: close_sinks
  final _permissionSubject = BehaviorSubject<LocationPermission>();

  LocationManager({
    required this.sharedPreferences,
  });

  Future<bool> get isEnabled => Geolocator.isLocationServiceEnabled();

  LocationPermission get permission => _permissionSubject.value;

  Stream<LocationPermission> get permissionStream => _permissionSubject.stream;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    await _checkPermission();
  }

  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    final deniedForever = _isDeniedForever;

    if (permission == LocationPermission.deniedForever && !deniedForever) {
      await sharedPreferences.setBool(deniedForeverKey, true);
      permission = LocationPermission.deniedForever;
    }

    _permissionSubject.add(permission);

    if (deniedForever) {
      await Geolocator.openAppSettings();
    }
  }

  Future<GeoPoint?> getLocation() async {
    final isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      return null;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition()
        .then((position) => GeoPoint(position.latitude, position.longitude));
  }

  bool get _isDeniedForever =>
      sharedPreferences.getBool(deniedForeverKey) ?? false;

  Future<void> _checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    final deniedForever = _isDeniedForever;

    if (permission == LocationPermission.denied && deniedForever) {
      permission = LocationPermission.deniedForever;
    }

    _permissionSubject.add(permission);
  }
}
