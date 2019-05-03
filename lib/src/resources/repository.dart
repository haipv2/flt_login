import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/resources/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  final _firestoreProvider = FirestoreProvider();

  Future<User> registerUser(User user) => _firestoreProvider.registerUser(user);

  Future<User> authenticateUser(String email, String password) async{
    var result = _firestoreProvider.authenticateUser(email,password);
    return result;
  }
}
