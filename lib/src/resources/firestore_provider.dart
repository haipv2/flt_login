import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/models/user_push.dart';

import '../common/common.dart';

class FirestoreProvider {
//  Firestore _firestore = Firestore.instance;
  FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<User> registerUser(User user) async {
    DatabaseReference child = _firebaseDatabase.reference().child(USERS_TBL);
    await child.push().set({
      'email': user.email,
      'first_name': user.firstname,
      'last_name': user.lastname,
      'password': user.password,
      'gender': user.gender,
      'user_role': user.role ?? 'USER'
    });
    return user;
  }

  Future<User> authenticateUser(String email, String password) async {
    DatabaseReference child = _firebaseDatabase.reference().child(USERS_TBL);
    DataSnapshot snapshot = await child.once();
    User user;

    Map<String, String> users = snapshot.value.cast<String, String>();

    users.forEach((key, userMap) {
//      userMap.
    });
    return user;
  }

  Future<void> registerUserPushInfo(UserPushInfo userPushInfo) async {
    String userInfoStr = json.encode(userPushInfo.toJson());
    var result = await FirebaseDatabase.instance
        .reference()
        .child(USER_PUSH_INFO)
        .push()
        .set({'email': userPushInfo.email, 'push_id': userPushInfo.pushId});
    return result;
  }

  Future<List<String>> getListPushIdViaEmail(String originEmail) async {
    DataSnapshot snapshot =
        await _firebaseDatabase.reference().child(USER_PUSH_INFO).once();
    Map<String, String> users = snapshot.value.cast<String, String>();
    List<String> result = [];
    users.forEach((key, userMap) {
//      print('KEY:======================= $key');
      var pushId = getPushId(originEmail, userMap);
      if (pushId != null) result.add(pushId);
    });
//    print(querySnapshot.documents);
    return result;
  }

  String getPushId(String email, String userMap) {
    UserPushInfo userPushInfo = UserPushInfo.fromJson(jsonDecode(userMap));
    if (userPushInfo.email == email) {
      return userPushInfo.pushId;
    }
    return null;
  }
}
