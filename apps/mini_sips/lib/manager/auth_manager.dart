import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../common/either.dart';
import '../domain/user_data.dart';

class AuthManager {
  static const String _appStyleKey = 'app_style';

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthManager({
    required this.firebaseAuth,
    required this.firestore,
  });

  Stream<bool> get isAuthStream =>
      firebaseAuth.authStateChanges().map((user) => user != null);

  bool get isAuth => firebaseAuth.currentUser != null;

  Future<bool> get isAppStyleSelected async {
    final userUid = firebaseAuth.currentUser?.uid;

    if (userUid == null) {
      return false;
    }

    final userCollection = firestore.collection('users').doc(userUid);
    final userDoc = await userCollection.get();
    return userDoc.data()?[_appStyleKey] != null;
  }

  Future<Either<Exception, void>> signInAnon() async {
    try {
      await firebaseAuth.signInAnonymously();
      return Either.right(null);
    } on Exception catch (e) {
      return Either.left(e);
    }
  }

  Future<Either<Exception, void>> setAppStyle(AppStyle appStyle) async {
    final userUid = firebaseAuth.currentUser?.uid;

    if (userUid == null) {
      return Either.left(Exception('User not found'));
    }

    try {
      final userCollection = firestore.collection('users').doc(userUid);
      await userCollection.set({
        _appStyleKey: appStyle.name,
      });
      return Either.right(null);
    } on Exception catch (e) {
      return Either.left(e);
    }
  }

  FEither<Exception, void> setUserData({
    required double? weight,
    required double? height,
    required int? age,
    required BiologicalSex sex,
  }) async {
    final userUid = firebaseAuth.currentUser?.uid;

    if (userUid == null) {
      return Either.left(Exception('User not found'));
    }

    try {
      final userCollection = firestore.collection('users').doc(userUid);
      await userCollection.set({
        'weight': weight,
        'height': height,
        'age': age,
        'sex': sex.name,
      });
      return Either.right(null);
    } on Exception catch (e) {
      return Either.left(e);
    }
  }
}
