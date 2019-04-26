import 'package:flt_login/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'login_bloc.dart';

class LoginBlocProvider extends InheritedWidget {
  var bloc = LoginBloc();
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  static LoginBloc of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(LoginBlocProvider) as LoginBlocProvider).bloc;
  }

}

