import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/ui/game_page.dart';
import 'package:flt_login/src/ui/login_page.dart';
import 'package:flt_login/src/ui/user_list_page.dart';
import 'package:flt_login/src/utils/map_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class MyPage extends StatefulWidget {
  final User user;
  SharedPreferences prefs;

  MyPage(this.user, {this.prefs});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        handleMessage(message);
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        handleMessage(message);
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        handleMessage(message);
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    updateFcmToken();
  }

  void handleMessage(Map<String, dynamic> message) async {
    var type = getValueFromMap(message, 'type');
    var fromId = getValueFromMap(message, 'fromId');

    print(type);
    if (type == 'invite') {
      showInvitePopup(context, message);
    } else if (type == 'accept') {
      var currentUser = await _auth.currentUser();

      String gameId = '${currentUser.uid}-$fromId';
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new Game(
              title: 'Tic Tac Toe',
              type: "wifi",
              me: 'X',
              gameId: gameId,
              withId: fromId)));
    } else if (type == 'reject') {}
  }

  void showInvitePopup(BuildContext context, Map<String, dynamic> message) {
    print(context == null);

    Timer(Duration(milliseconds: 200), () {
      showDialog<bool>(
        context: context,
        builder: (_) => buildDialog(context, message),
      );
    });
  }

  Widget buildDialog(BuildContext context, Map<String, dynamic> message) {
    var fromName = getValueFromMap(message, 'fromName');

    return AlertDialog(
      content: Text('$fromName invites you to play!'),
      actions: <Widget>[
        FlatButton(
          child: Text('Decline'),
          onPressed: () {},
        ),
        FlatButton(
          child: Text('Accept'),
          onPressed: () {
            accept(message);
          },
        ),
      ],
    );
  }

  void accept(Map<String, dynamic> message) async {
    String fromPushId = getValueFromMap(message, 'fromPushId');
    String fromId = getValueFromMap(message, 'fromId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString(USER_NAME);
    var pushId = prefs.getString(PUSH_ID);
    var userId = prefs.getString(USER_ID);

    var base = 'https://us-central1-tictactoe-64902.cloudfunctions.net';
    String dataURL =
        '$base/sendNotification2?to=$fromPushId&fromPushId=$pushId&fromId=$userId&fromName=$username&type=accept';
    print(dataURL);
    http.Response response = await http.get(dataURL);

    String gameId = '$fromId-$userId';

    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new Game(
            title: 'Tic Tac Toe',
            type: "wifi",
            me: 'O',
            gameId: gameId,
            withId: fromId)));
  }

  // Not sure how FCM token gets updated yet
  // just to make sure correct one is always set
  void updateFcmToken() async {
    var currentUser = await _auth.currentUser();
    if (currentUser != null) {
      var token = await firebaseMessaging.getToken();
      print(token);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(PUSH_ID, token);

      FirebaseDatabase.instance
          .reference()
          .child(USERS)
          .child(currentUser.uid)
          .update({PUSH_ID: token});
      print('updated FCM token');
    }
  }

  @override
  Widget build(BuildContext context) {
    var singleMode = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          print('print single mode');
//          Navigator.pushNamed(context, ARENA);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Game(
                    title: 'Game title',
                    prefs: widget.prefs,
                  )));
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Single mode', style: TextStyle(color: Colors.white)),
      ),
    );
    var playWithFriend = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          print('play with friends');
          openFriendList();
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Play with friends', style: TextStyle(color: Colors.white)),
      ),
    );
    ;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('demo login'),
        ),
        drawer: myPageDrawer(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            singleMode,
            Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            ),
            playWithFriend,
            Container(
              margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
            )
          ],
        ),
      ),
    );
  }

  Widget myPageDrawer() {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 3 / 4,
      child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          elevation: 2,
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(widget.user.firstname),
                accountEmail: Text(widget.user.email),
                currentAccountPicture: CircleAvatar(
                  child: widget.user.gender == 1
                      ? Image.asset('assets/images/male.png')
                      : Image.asset('assets/images/female.png'),
                  backgroundColor: Colors.white,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  // Update the state of the app
                  // ...
                  // Then close the drawer
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    if (widget.prefs != null) widget.prefs.remove('user');
                    return Loginpage(widget.prefs);
                  }));
                },
              ),
            ],
          )),
    );
  }

  void openFriendList() async {
    FirebaseUser user = await signInWithGoogle();
    await saveUserToFirebase(user);
//    Navigator.of(context).pushNamed('userList');
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => UserList()));
  }

  Future<FirebaseUser> signInWithGoogle() async {
    var user = await _auth.currentUser();
    if (user == null) {
      GoogleSignInAccount googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        googleUser = await _googleSignIn.signInSilently();
        if (googleUser == null) {
          googleUser = await _googleSignIn.signIn();
        }
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = await _auth.signInWithCredential(credential);

      print("signed in as " + user.displayName);
    }

    return user;
  }

  Future<void> saveUserToFirebase(FirebaseUser user) async {
    print('saving user to firebase');
    var token = await firebaseMessaging.getToken();

    await saveUserToPreferences(user.uid, user.displayName, token);

    var update = {
      NAME: user.displayName,
      PHOTO_URL: user.photoUrl,
      PUSH_ID: token
    };
    return FirebaseDatabase.instance
        .reference()
        .child(USERS)
        .child(user.uid)
        .update(update);
  }

  saveUserToPreferences(String userId, String userName, String pushId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(USER_ID, userId);
    prefs.setString(PUSH_ID, pushId);
    prefs.setString(USER_NAME, userName);
  }
}
