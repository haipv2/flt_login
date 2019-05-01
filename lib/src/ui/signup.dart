import 'package:flt_login/src/blocs/signup_bloc.dart';
import 'package:flt_login/src/ui/widgets/custom_flat_button.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController firstNameController = new TextEditingController();
  TextEditingController lastNameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController passwordConfirmController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  SignupBloc _signUpBloc;
  @override
  void initState() {
    _signUpBloc = SignupBloc();
    super.initState();
  }
  @override
  void dispose() {
    _signUpBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fistName() => StreamBuilder(
        stream: _signUpBloc.firstNameStream,
        builder: (context, snapshot) {
      return Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: TextField(
          autofocus: false,
          controller: firstNameController,
          decoration: InputDecoration(
              labelText: 'First Name',
              hintText: 'Enter first name',
              errorText: snapshot.error,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  borderSide: BorderSide(color: Colors.grey, width: 1))),

        ),
      );
    });
    var lastName = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        autofocus: false,
        controller: lastNameController,
        decoration: InputDecoration(
            labelText: 'Last Name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
    var email = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        autofocus: false,
        controller: emailController,
        decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
    var password = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        obscureText: true,
        autofocus: false,
        controller: passwordController,
        decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
    var passwordConfirm = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        autofocus: false,
        obscureText: true,
        controller: passwordConfirmController,
        decoration: InputDecoration(
            labelText: 'Confirm password',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                borderSide: BorderSide(color: Colors.grey, width: 1))),
      ),
    );
    var registerButton = CustomFlatButton(
      title: "Register",
      fontSize: 15,
      fontWeight: FontWeight.w400,
      textColor: Colors.white,
      onPressed: () {
        _doRegister();
      },
      splashColor: Colors.black12,
      borderColor: Color.fromRGBO(59, 89, 152, 1.0),
      borderWidth: 0,
      color: Colors.blue,
    );
    var registerByOtherWay = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: CustomFlatButton(
            title: "Facebook Login",
            fontSize: 8,
            fontWeight: FontWeight.w300,
            textColor: Colors.white,
            onPressed: () {
              _facebookLogin(context: context);
            },
            splashColor: Colors.black12,
            borderColor: Color.fromRGBO(59, 89, 152, 1.0),
            borderWidth: 0,
            color: Color.fromRGBO(59, 89, 152, 1.0),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 1.0),
          child: Text('OR',
              style: TextStyle(
                color: Colors.grey,
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: CustomFlatButton(
            title: "Google login",
            fontSize: 8,
            fontWeight: FontWeight.w300,
            textColor: Colors.red,
            onPressed: () {
              _gooogleLogin(context: context);
            },
            splashColor: Colors.black12,
            borderColor: Color.fromRGBO(59, 89, 152, 1.0),
            borderWidth: 0,
            color: Colors.white,
          ),
        ),
      ],
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            fistName(),
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            lastName,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            email,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            password,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            passwordConfirm,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            registerButton,
            Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            ),
            registerByOtherWay,
          ],
        ),
      ),
    );
  }

  void _doRegister() {
    print('do register');
  }

  void _facebookLogin({BuildContext context}) {
    print('facebook login');
  }

  void _gooogleLogin({BuildContext context}) {
    print('BEGIN: google login');
  }
}
