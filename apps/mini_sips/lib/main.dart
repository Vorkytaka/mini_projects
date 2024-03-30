import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dependencies.dart';
import 'firebase_options.dart';
import 'manager/location_manager.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final firebase = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final locationManager = LocationManager(sharedPreferences: sharedPreferences);
  await locationManager.init();

  final Dependencies dependencies = DependenciesImpl(
    firebase: firebase,
    locationManager: locationManager,
    sharedPreferences: sharedPreferences,
  );

  runApp(App(dependencies: dependencies));
}
