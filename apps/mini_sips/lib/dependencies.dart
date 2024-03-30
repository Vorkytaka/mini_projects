import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'manager/auth_manager.dart';
import 'manager/data_manager.dart';
import 'manager/location_manager.dart';

abstract class Dependencies {
  FirebaseApp get firebase;

  FirebaseAuth get firebaseAuth;

  FirebaseFirestore get firebaseFirestore;

  AuthManager get authManager;

  DataManager get dataManager;

  LocationManager get locationManager;

  SharedPreferences get sharedPreferences;
}

class DependenciesImpl implements Dependencies {
  @override
  final FirebaseApp firebase;

  @override
  final LocationManager locationManager;

  @override
  final SharedPreferences sharedPreferences;

  DependenciesImpl({
    required this.firebase,
    required this.locationManager,
    required this.sharedPreferences,
  });

  @override
  FirebaseAuth get firebaseAuth => FirebaseAuth.instanceFor(app: firebase);

  @override
  FirebaseFirestore get firebaseFirestore =>
      FirebaseFirestore.instanceFor(app: firebase);

  @override
  late final AuthManager authManager = AuthManager(
    firebaseAuth: firebaseAuth,
    firestore: firebaseFirestore,
  );

  @override
  late final DataManager dataManager = DataManager(
    auth: firebaseAuth,
    firestore: firebaseFirestore,
  );
}
