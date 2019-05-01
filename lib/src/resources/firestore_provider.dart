import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/common.dart';

class FirestoreProvider {
  Firestore _firestore = Firestore.instance;

  Future<void> registerUser(
      String email, String password, String username, String userphone, String userRole) async {
    return _firestore.collection(USERS_TBL).document().setData({
      'email': email,
      'username': username,
      'password': password,
      'userphone': userphone,
      'user_role': userRole ?? 'USER'
    });
  }
}
