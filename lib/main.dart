import 'package:flt_login/src/ui/login_page.dart';
import 'package:flt_login/src/ui/signup.dart';
import 'package:flt_login/src/ui/splash/splash_page.dart';
import 'package:flutter/material.dart';
import './src/common/common.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo app',
      home: Scaffold(
        body: Loginpage(),
      ),
//      routes: <String, WidgetBuilder>{
//        '/splash' : (context) => SplashPage()
//      },
//      routes: <String, WidgetBuilder>{
//        SIGN_UP: (BuildContext context) => SignUp(),
//      },
    );
  }
}

