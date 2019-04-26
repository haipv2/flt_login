import 'package:flutter/material.dart';

class Loginpage extends StatefulWidget {
  @override
  _LoginpageState createState() => _LoginpageState();
}

class _LoginpageState extends State<Loginpage> {

  TextEditingController emailController = new TextEditingController();
  TextEditingController passController = new TextEditingController();
//  LogicBloc _bloc;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var imageLogin = Container(
            width: 150,
            height: 150,
            child: Image.asset("assets/images/login.png"),
            decoration: BoxDecoration(shape: BoxShape.circle),
          );
    var textLogin = Text('Login Page');
    var emailTextField = Padding(
            padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: TextField(
              autofocus: false,
              controller: emailController,
              decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
          );
    var passwordField = Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextField(
              autofocus: false,
              controller: passController,
              obscureText: true,
              decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.grey, width: 1))),
            ),
          );
    var loginButton = RaisedButton(
      child: Text('Login'),
      textColor: Colors.white,
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      onPressed: null,
    );
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          imageLogin,
          Container(margin: EdgeInsets.only(top: 5.0,bottom: 5.0),),
          textLogin,
          Container(margin: EdgeInsets.only(top: 10.0,bottom: 10.0),),
          emailTextField,
          Container(margin: EdgeInsets.only(top: 5.0,bottom: 5.0),),
          passwordField,
          Container(margin: EdgeInsets.only(top: 10.0,bottom: 10.0),),
          loginButton,
        ],
      ),
    );
  }
}
