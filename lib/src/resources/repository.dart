import 'package:flt_login/src/resources/firestore_provider.dart';
import 'package:flutter/material.dart';

class Repository {
  final _firestoreProvider = FirestoreProvider();

  Future<void> registerUser(
          String email, String password, String username, String userphone) =>
      _firestoreProvider.registerUser(email, password, username, userphone);
}
