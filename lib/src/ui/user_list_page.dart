import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/blocs/user_push_bloc.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/utils/shared_preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  final String title;
  final String currentEmail;

  UserList(this.currentEmail, {Key key, this.title}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> _users = List<User>();
  UserPushBloc _userPushBloc;

  @override
  void initState() {
    fetchUsers(widget.currentEmail);
    _userPushBloc = new UserPushBloc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
            itemCount: _users.length,
            itemBuilder: (context, index) => buildListRow(context, index)));
  }

  Widget buildListRow(BuildContext context, int index) => InkWell(
        onTap: () {
          Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Send a challenge request to ${_users[index].firstname}')));
          challenge(_users[index]);
        },
        child: ListTile(
          leading: _users[index].gender == 0
              ? Image.asset('assets/images/female.png')
              : Image.asset('assets/images/male.png'),
          title: Text('${_users[index].firstname}${_users[index].lastname}'),
        ),
      );

  void fetchUsers(String currentEmail) async {
    var snapshot =
        await FirebaseDatabase.instance.reference().child(USERS).once();

    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    users.forEach((userId, userMap) {
      User user = parseUser(userId, userMap, currentEmail);
      if (user != null) {
        setState(() {
          _users.add(user);
        });
      }
    });
  }

  User parseUser(
      String userId, Map<dynamic, dynamic> user, String currentEmail) {
    String name, photoUrl, pushId, email, firstname, lastname;
    int gender;
    String emailFromDb = user['email'];
    if (emailFromDb == currentEmail) {
      return null;
    } else {
      user.forEach((key, value) {
        if (key == 'email') {
          email = value as String;
        }
        if (key == NAME) {
          name = value as String;
        }
        if (key == PHOTO_URL) {
          photoUrl = value as String;
        }
        if (key == PUSH_ID) {
          pushId = value as String;
        }
        if (key == 'first_name') {
          firstname = value as String;
        }
        if (key == 'last_name') {
          lastname = value as String;
        }
        if (key == 'gender') {
          gender = int.parse(value);
        }
      });

      return User.userForPush(userId, name, photoUrl, pushId)
        ..firstname = firstname
        ..lastname = lastname
        ..email = email
        ..gender = gender;
    }
  }

  challenge(User user) async {

//    var userVar = SharedPreferencesUtils.getUserFromPreferences();
//    User user = userVar as User;
    var pushId = await SharedPreferencesUtils.getStringToPreferens(PUSH_ID);

    List<String> pushIds =await _userPushBloc.getListPushIdViaEmail(user.email);

    var username = user.firstname;
//    var pushId = prefs.getString(PUSH_ID);
    var email = user.email;
    var base = 'https://us-central1-testproject-fbdaf.cloudfunctions.net';

    pushIds.forEach((item) {
      String dataURL =
          '$base/sendNotification2?to=${item}&fromPushId=$pushId&fromId=$email&fromName=$username&type=invite';
      print(dataURL);
      String gameId = '$email-${user.userId}';
      FirebaseDatabase.instance
          .reference()
          .child(GAME_TBL)
          .child(gameId)
          .set(null);
      http.get(dataURL);
    });
  }
}
