import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/models/user_push.dart';

import '../common/common.dart';

class FirestoreProvider {
  Firestore _firestore = Firestore.instance;

  Future<User> registerUser(User user) async {
    QuerySnapshot result = await _firestore
        .collection(USERS_TBL)
        .where("email", isEqualTo: user.email)
        .getDocuments();

    if (result.documents.length > 0) {
      return null;
    }
    _firestore.collection(USERS_TBL).document().setData({
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
    QuerySnapshot result = await _firestore
        .collection(USERS_TBL)
        .where("email", isEqualTo: email)
        .where("password", isEqualTo: password)
        .getDocuments();
    if (result.documents.length == 0) {
      return null;
    } else {
      User user = User.fromJson(result.documents[0].data);
      return user;
    }
  }

  Future<void> registerUserPushInfo(UserPushInfo userPushInfo) async {
    String userInfoStr = json.encode(userPushInfo.toJson()) ;
    var result = await FirebaseDatabase.instance
        .reference()
        .child(USER_PUSH_INFO)
        .set(userInfoStr);
    return result;
  }

  Future<List<String>> getListPushIdViaEmail(String email) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(USER_PUSH_INFO)
        .reference()
        .where('email', isEqualTo: email)
        .getDocuments();
    List<String> result = [];
    print(querySnapshot.documents);
    return result;
  }
}
