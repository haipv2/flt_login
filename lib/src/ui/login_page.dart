import 'package:flt_login/src/ui/signup_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../common/common.dart';

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
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
    var loginButton = RaisedButton(
      child: Text('Login'),
      textColor: Colors.white,
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: null,
    );
    var registerUser = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          RichText(
            text: TextSpan(
                text: 'New user? ',
                style: TextStyle(color: Colors.black),
                recognizer: TapGestureRecognizer()..onTap = () {},
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = signUpUser,
                    text: 'Sign up',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ]),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: _forgotPassword,
              child: Text(
                'Forgot password ?',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageLogin,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            textLogin,
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            ),
            emailTextField,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            passwordField,
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            ),
            loginButton,
            Container(margin: EdgeInsets.fromLTRB(10, 20, 10, 0)),
            registerUser,
          ],
        ),
      ),
    );
  }

  void _forgotPassword() {
    print('press forget password');

  }

  void signUpUser() async{
    print('signup user');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));

  }
}
