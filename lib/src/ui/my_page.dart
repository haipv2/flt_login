import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/ui/game_page.dart';
import 'package:flt_login/src/ui/login_page.dart';
import 'package:flt_login/src/ui/user_list_page.dart';
import 'package:flt_login/src/utils/map_utils.dart';
import 'package:flt_login/src/utils/shared_preferences_utils.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/game_enums.dart';

class MyPage extends StatefulWidget {
  final User user;

  MyPage(this.user){
  }

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with TickerProviderStateMixin {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AnimationController _controller;
  Animation _firstAnimationMenu;
  AnimationController _controllerHide;
  Animation _lateAnimationMenu;
  AnimataionCommonStatus animataionCommonStatus;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _controllerHide =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _firstAnimationMenu = Tween(begin: -1.0, end: 0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animataionCommonStatus = AnimataionCommonStatus.open;
        } else if (status == AnimationStatus.dismissed) {
          animataionCommonStatus = AnimataionCommonStatus.closed;
        } else {
          animataionCommonStatus = AnimataionCommonStatus.animating;
        }
      });
    _lateAnimationMenu = Tween(begin: -1.0, end: 0).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 1.0, curve: Curves.fastOutSlowIn)));

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
    var type = getValueFromMapData(message, 'type');
    var fromId = getValueFromMapData(message, 'fromId');

    print(type);
    if (type == 'invite') {
      showInvitePopup(context, message);
    } else if (type == 'accept') {
      var currentUser = await _auth.currentUser();

      String gameId = '${currentUser.uid}-$fromId';
      Navigator.of(context).push(new MaterialPageRoute(
          builder: (context) => new Game(
                GameMode.friends,
                null,
                null,
              )));
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
    var fromName = getValueFromMapData(message, 'fromName');

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

    var base = 'https://us-central1-testproject-fbdaf.cloudfunctions.net';
    String dataURL =
        '$base/sendNotification2?to=$fromPushId&fromPushId=$pushId&fromId=$userId&fromName=$username&type=accept';
    print(dataURL);
    http.Response response = await http.get(dataURL);
    String gameId = '$fromId-$userId';
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (context) => new Game(
              GameMode.friends,
              null,
              null,
            )));
  }

  // Not sure how FCM token gets updated yet
  // just to make sure correct one is always set
  void updateFcmToken() async {
    var currentUser = await _auth.currentUser();
    if (currentUser != null) {
      var token = await firebaseMessaging.getToken();
      print(token);

      SharedPreferencesUtils.setStringToPreferens(PUSH_ID, token);

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
    double width = MediaQuery.of(context).size.width;
    _controller.forward().orCancel;
    Widget singleMode() => Transform(
          transform: Matrix4.translationValues(
              _firstAnimationMenu.value * width, 0, 0),
          child: ButtonTheme(
            minWidth: 200.0,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                onPressed: () {
                  print('print single mode');
//                  _hideMenuAnimate();
                  Navigator.pushNamed(context, ARENA);
                },
                padding: EdgeInsets.all(12),
                color: Colors.lightBlueAccent,
                child:
                    Text('Single mode', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        );
    Widget playWithFriend() => Transform(
        transform: Matrix4.translationValues(
            _firstAnimationMenu.value * width, 0.0, 0.0),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: ButtonTheme(
            minWidth: 200.0,
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
              child: Text('Play with friends',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ));
    Widget quit() => Transform(
        transform: Matrix4.translationValues(
            _lateAnimationMenu.value * width, 0.0, 0.0),
        child: ButtonTheme(
          minWidth: 200.0,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () {
                print('Quit');
                exit(0);
              },
              padding: EdgeInsets.all(12),
              color: Colors.lightBlueAccent,
              child: Text('Quit', style: TextStyle(color: Colors.white)),
            ),
          ),
        ));

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('demo login'),
//            leading: Container(),
          ),
          drawer: myPageDrawer(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              singleMode(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              ),
              playWithFriend(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              ),
              quit(),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
              )
            ],
          ),
        );
      },
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
                leading: const Icon(Icons.account_circle),
                title: Text('User\'s info'),
                onTap: () {
                  Navigator.pushNamed(context, USER_INFO);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text('Logout'),
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                        removeUserInfo();
                    return Loginpage();
                  }));
                },
              ),
            ],
          )),
    );
  }

  void openFriendList() async {
//    FirebaseUser user = await signInWithGoogle();
//    await saveUserToFirebase(user);
////    Navigator.of(context).pushNamed('userList');
//    Navigator.of(context).pushReplacement(MaterialPageRoute(
//        builder: (context) => UserList(
//              title: 'Friend list',
//            )));
  Navigator.pushNamed(context, FRIENDS_LIST);

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

  void removeUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(USER_PREFS_KEY);

  }
}
