import 'dart:convert';

import 'package:flt_login/src/blocs/login_bloc_provider.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/ui/game_page.dart';
import 'package:flt_login/src/ui/login_page.dart';
import 'package:flt_login/src/ui/my_page.dart';
import 'package:flt_login/src/ui/user_info_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/common/game_enums.dart';
import 'src/ui/user_list_page.dart';

void main() {
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences preferences;
  User user;

  MyApp(this.preferences);

  @override
  Widget build(BuildContext context) {
    String userJson = preferences.getString(USER_PREFS_KEY);

    if (userJson != null && userJson.isNotEmpty) {
      Map userMap = jsonDecode(userJson);
      user = User.fromJson(userMap);
    }

    return LoginBlocProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Demo app',
        home: Scaffold(body: user == null ? Loginpage() : MyPage(user)),
        routes: <String, WidgetBuilder>{
          MYPAGE: (BuildContext context) => MyPage(user),
          USER_INFO: (BuildContext context) => UserInfo(user),
          FRIENDS_LIST: (BuildContext context) => UserList(
                user.email,
                title: 'List your friends',
              ),
          ARENA: (BuildContext context) => Game(
                GameMode.single,
                user,
                User()
                  ..firstname = 'AI'
                  ..userId = 'AI id'
                  ..name = 'AI name',
              ),
        },
      ),
    );
  }
}
