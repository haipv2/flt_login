import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/resources/repository.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class LoginBloc {
  final _repository = Repository();
  final _userEmailController = BehaviorSubject<String>();
  final _userPasswordController = BehaviorSubject<String>();
  final _loginStreamController = PublishSubject<void>();

  //Stream
  Observable<String> get emailStream => _userEmailController.stream;

  Observable<String> get passwordStream => _userPasswordController.stream;

  Observable<void> get loginStream => _loginStreamController.stream;

  Function(void) get doLoginStream => _loginStreamController.sink.add;

  //add input
  Function(String) get emailStreamChange => _userEmailController.sink.add;
  Function(String) get passwordStreamChange => _userPasswordController.sink.add;

  Future<User> authenticateUser() {
    return _repository.authenticateUser(
        _userEmailController.value, _userPasswordController.value);
  }

  void dispose() async {
    await _userEmailController.drain();
    _userEmailController.close();
    await _userPasswordController.drain();
    _userPasswordController.close();
  }
}
