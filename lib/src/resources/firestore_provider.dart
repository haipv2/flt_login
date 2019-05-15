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
    await child.push().set(<String, String>{
      'email': user.email,
      'first_name': user.firstname,
      'last_name': user.lastname,
      'password': user.password,
      'gender': user.gender.toString(),
      'user_role': user.role ?? 'USER'
    });
    return user;
  }

  Future<User> authenticateUser(String email, String password) async {
    DatabaseReference child = _firebaseDatabase.reference().child(USERS_TBL);
    DataSnapshot snapshot = await child.once();
    User user;
    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    users.forEach((key, userMap) {
      getUserByEmailPassword(email, password, userMap);
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
    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    List<String> result = [];
    users.forEach((key, userMap) {
//      print('KEY:======================= $key');
      var pushId = getPushId(originEmail, userMap);
      if (pushId != null) result.add(pushId);
    });
//    print(querySnapshot.documents);
    return result;
  }

  String getPushId(String email, Map<dynamic,dynamic> userMap) {
    String pushId;
    userMap.forEach((key,value){
      if (key=='push_id') {
        pushId = value.toString();
      }
    });
    return pushId;
  }

  User getUserByEmailPassword(
      String emailInput, String passwordInput, Map<String, String> userMap) {
    String email, password, firstName, lastName;
    int gender;
    userMap.forEach((key, value) {
      if (key == 'email') {
        email = value.toString();
      } else if (key == 'password') {
        password = value.toString();
      } else if (key == 'first_name') {
        firstName = value.toString();
      } else if (key == 'last_name') {
        lastName = value.toString();
      } else if (key == 'gender') {
        gender = int.parse(value);
      }
    });
    if (email == emailInput && password == passwordInput) {
      return User()
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
