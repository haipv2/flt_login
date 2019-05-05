import 'package:flt_login/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  final User user;
  SharedPreferences prefs;

  MyPage(this.user, {this.prefs});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
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
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => GamePage(title: 'Game title',)));
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Single mode ${widget.user.firstname}',
            style: TextStyle(color: Colors.white)),
      ),
    );
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
          semanticLabel: 'SEMANTICLABEL',
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
}
