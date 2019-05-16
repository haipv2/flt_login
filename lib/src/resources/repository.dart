import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/models/user_push.dart';
import 'package:flt_login/src/resources/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Repository {
  final _firestoreProvider = FirestoreProvider();

  Future<User> registerUser(User user) async {
    var result = await _firestoreProvider.registerUser(user);
    return result;
  }

  Future<User> authenticateUser(String loginId, String password) async {
    var result = _firestoreProvider.authenticateUser(loginId, password);
    return result;
  }

  Future<void> registerUserPushInfo(UserPushInfo userPushInfo) async {
    var result = await _firestoreProvider.registerUserPushInfo(userPushInfo);
    return result;
  }

  Future<List<String>> getListPushIdViaEmail(String email) async{
    var result =await _firestoreProvider.getListPushIdViaEmail(email);
    return result;
  }
}
