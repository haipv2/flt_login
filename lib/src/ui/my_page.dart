import 'package:flt_login/src/models/user.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  final User user;

  MyPage(this.user);

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
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Single mode ${widget.user.firstname}',
            style: TextStyle(color: Colors.white)),
      ),
    );
    return Scaffold(
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
    );
  }

  Widget myPageDrawer() => Drawer(
        child: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the Drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    children: <Widget>[
                      widget.user.gender == 1
                          ? Image.asset('assets/images/male.png')
                          : Image.asset('assets/images/female.png'),
                      Text('Welcome ${widget.user.firstname}'),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Item 1'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Item 2'),
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
              ]),
        ),
      );
}
