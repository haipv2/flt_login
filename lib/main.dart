import 'dart:convert';

import 'package:flt_login/src/blocs/login_bloc_provider.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/ui/game_page.dart';
import 'package:flt_login/src/ui/login_page.dart';
import 'package:flt_login/src/ui/my_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;

  MyApp(this.preferences);

  @override
  Widget build(BuildContext context) {
    String userJson = preferences.getString('user');
    User user;
    if (userJson != null && userJson.isNotEmpty) {
      Map userMap = jsonDecode(userJson);
      user = User.fromJson(userMap);
    }

    return LoginBlocProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Demo app',
        home: Scaffold(
            body: user == null
                ? Loginpage(preferences)
                : MyPage(
                    user,
                    prefs: preferences,
                  )),
        routes: <String, WidgetBuilder>{
          MYPAGE: (BuildContext context) =>
              MyPage(
                user,
                prefs: preferences,
              ),
          ARENA: (BuildContext context) =>
              Game(
                title: 'ARENA',
              ),
        },
      ),
    );
  }
}
