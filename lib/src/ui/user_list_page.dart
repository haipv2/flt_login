import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  final String title;

  UserList({Key key, this.title}) : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList>
    with SingleTickerProviderStateMixin {
  List<User> _users = List<User>();
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;
  bool isOpened = false;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

//  Widget inviteViaEmail() {
//    return Container(
//      child: FloatingActionButton(
//        onPressed: null,
//        tooltip: 'Invite',
//        child: Icon(Icons.add),
//      ),
//    );
//  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.blue,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
//    fetchUsers();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text(widget.title),
//      ),
//      body:
//          ListView.builder(itemCount: _users.length, itemBuilder: buildListRow),
//      floatingActionButton:
//          Container(child: FloatingActionButton(onPressed: toggle)),
//    );
//  }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[

//        Transform(
//          transform: Matrix4.translationValues(
//            0.0,
//            _translateButton.value * 3.0,
//            0.0,
//          ),
//          child: inviteViaEmail(),
//        ),
        toggle(),
      ],
    );
  }

  Widget buildListRow(BuildContext context, int index) => Container(
      height: 56.0,
      child: InkWell(
          onTap: () {
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text('Clicked on ${_users[index].name}')));
            invite(_users[index]);
          },
          child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                '${_users[index].name}',
                // Some weird bugs if passed without quotes
                style: TextStyle(fontSize: 18.0),
              ))));

  void fetchUsers() async {
    var snapshot =
        await FirebaseDatabase.instance.reference().child(USERS).once();

    Map<String, dynamic> users = snapshot.value.cast<String, dynamic>();
    users.forEach((userId, userMap) {
      User user = parseUser(userId, userMap);
      setState(() {
        _users.add(user);
      });
    });
  }

  User parseUser(String userId, Map<dynamic, dynamic> user) {
    String name, photoUrl, pushId;
    user.forEach((key, value) {
      if (key == NAME) {
        name = value as String;
      }
      if (key == PHOTO_URL) {
        photoUrl = value as String;
      }
      if (key == PUSH_ID) {
        pushId = value as String;
      }
    });

    return User.userForPush(userId, name, photoUrl, pushId);
  }

  invite(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var username = prefs.getString(USER_NAME);
    var pushId = prefs.getString(PUSH_ID);
    var userId = prefs.getString(USER_ID);

    var base = 'https://us-central1-testproject-fbdaf.cloudfunctions.net';
    String dataURL =
        '$base/sendNotification2?to=${user.pushId}&fromPushId=$pushId&fromId=$userId&fromName=$username&type=invite';
    print(dataURL);
    String gameId = '$userId-${user.userId}';
    FirebaseDatabase.instance
        .reference()
        .child(GAME_TBL)
        .child(gameId)
        .set(null);
    http.Response response = await http.get(dataURL);
  }
}
