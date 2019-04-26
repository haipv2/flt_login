import 'package:flt_login/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final _repositor = Repository();
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _isSignedIn = BehaviorSubject<bool>();

  Observable<String> get emailStream => _email.stream;

  Observable<String> get passwordStream => _password.stream;

  Observable<bool> get signInStatus => _isSignedIn.stream;

}

