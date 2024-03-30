import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../common/either.dart';
import '../domain/alcohol.dart';

class DataManager {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  DataManager({
    required this.auth,
    required this.firestore,
  });

  FEither<Exception, void> addDrink(Alcohol alcohol) async {
    final userUid = auth.currentUser?.uid;

    if (userUid == null) {
      return Either.left(Exception('No user found'));
    }

    try {
      final userDocument = firestore.collection('users').doc(userUid);
      final userAlcoholCollection = userDocument.collection('alcohol');

      await userAlcoholCollection.add(alcohol.toJson);

      return Either.right(null);
    } on Exception catch (e) {
      return Either.left(e);
    }
  }
}
