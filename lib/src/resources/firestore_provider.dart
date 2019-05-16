import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/models/user_push.dart';

import '../common/common.dart';

class FirestoreProvider {
//  Firestore _firestore = Firestore.instance;
  FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;

  Future<User> registerUser(User user) async {
    DatabaseReference child = _firebaseDatabase.reference().child(USERS_TBL);
    await child.child(user.loginId).set(<String, String>{
      USER_EMAIL: user.email,
      USER_FIRST_NAME: user.firstname,
      USER_LAST_NAME: user.lastname,
      USER_PASSWORD: user.password,
      USER_GENDER: user.gender.toString(),
      USER_ROLE: user.role ?? 'USER'
    });
    return user;
  }

  Future<User> authenticateUser(String loginId, String password) async {
    DatabaseReference child = _firebaseDatabase.reference().child(USERS_TBL);
    DataSnapshot snapshot = await child.once();
    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    User result;
    users.forEach((key, userMap) {
      if (key == loginId)
        result = getUserByLoginAndPassword(loginId, password, userMap);
    });

    return result;
  }

  Future<void> registerUserPushInfo(UserPushInfo userPushInfo) async {
    String userInfoStr = json.encode(userPushInfo.toJson());
    var result = await FirebaseDatabase.instance
        .reference()
        .child(USER_PUSH_INFO)
        .push()
        .set({
      USER_PUSH_LOGIN_ID: userPushInfo.loginId,
      USER_PUSH_PUSH_ID: userPushInfo.pushIds
    });
    return result;
  }

  Future<List<String>> getListPushIdViaEmail(String friendsEmail) async {
    DataSnapshot snapshot =
        await _firebaseDatabase.reference().child(USER_PUSH_INFO).once();
    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    List<String> result = [];
    users.forEach((key, userMap) {
//      print('KEY:======================= $key');
      var pushId = getPushId(friendsEmail, userMap);
      if (pushId != null) result.add(pushId);
    });
//    print(querySnapshot.documents);
    return result;
  }

  String getPushId(String friendsEmail, Map<dynamic, dynamic> userMap) {
    String pushId;
    String email;
    userMap.forEach((key, value) {
      if (key == 'push_id') {
        pushId = value.toString();
      }
      if (key == USER_EMAIL) {
        email = value.toString();
      }
    });
    if (email == friendsEmail) {
      return pushId;
    } else {
      return null;
    }
  }

  User getUserByLoginAndPassword(String loginIdInput, String passwordInput,
      Map<dynamic, dynamic> userMap) {
    String email, password, firstName, lastName;
    int gender;
    userMap.forEach((key, value) {
      if (key == USER_EMAIL) {
        email = value.toString();
      } else if (key == USER_PASSWORD) {
        password = value.toString();
      } else if (key == USER_FIRST_NAME) {
        firstName = value.toString();
      } else if (key == USER_LAST_NAME) {
        lastName = value.toString();
      } else if (key == USER_GENDER) {
        gender = int.parse(value);
      }
    });
    if (password == passwordInput) {
      return User()
        ..loginId = loginIdInput
        ..email = email
        ..firstname = firstName
        ..lastname = lastName
        ..email = email
        ..password = password
        ..gender = gender;
    }
    return null;
  }
}
