import 'package:flt_login/src/ui/login_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo app',
      home: Scaffold(
        body: Loginpage(),
      ),
    );
  }
}

