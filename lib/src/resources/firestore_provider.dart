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
    var result = await FirebaseDatabase.instance
        .reference()
        .child(USER_PUSH_INFO)
        .child(userPushInfo.loginId)
        .set({USER_PUSH_PUSH_ID: userPushInfo.pushIds});
    return result;
  }

  Future<List<dynamic>> getListPushIdViaLoginId(String friendsLoginId) async {
    DataSnapshot snapshot =
        await _firebaseDatabase.reference().child(USER_PUSH_INFO).once();
    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    List<dynamic> result = [];
    users.forEach((key, userMap) {
      if (key != friendsLoginId) return;
      List<dynamic> pushId = getPushId(friendsLoginId, userMap);
      result.addAll(pushId);
    });
    return result;
  }

  List<dynamic> getPushId(
      String friendsLoginId, Map<dynamic, dynamic> userMap) {
    List<dynamic> pushId;
    userMap.forEach((key, value) {
      if (key == USER_PUSH_PUSH_ID) {
        pushId = value;
      }
    });
    return pushId;
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

  Future<User> getUserByLogin(loginIdInput)async {
    DataSnapshot snapshot = await
        _firebaseDatabase.reference().child(USERS_TBL).once();
    print('object');

    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    User result;
    String email, password, firstName, lastName;
    int gender;
    users.forEach((key, value) {
      if (key == loginIdInput) {
        result = getUserInMapByLogin(value);
        result.loginId = loginIdInput;
      }
    });

    return result;
  }

  User getUserInMapByLogin(Map<dynamic, dynamic> userMap) {
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
    var result = User()
      ..email = email
      ..firstname = firstName
      ..lastname = lastName
      ..email = email
      ..password = password
      ..gender = gender;
    return result;
  }
}
