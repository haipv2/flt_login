import 'dart:async';

import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/resources/repository.dart';
import 'package:flt_login/src/utils/validator_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginBloc {
  final _repository = Repository();
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final _userEmailController = BehaviorSubject<String>();
  final _userPasswordController = BehaviorSubject<String>();
  final _loginStreamController = PublishSubject<bool>();
  final _imageStreamLoginController = BehaviorSubject<String>();

  final _changeImage =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.length == 3) {
      print('enter 3 characters');
      sink.add('new image');
    }
  });

  StreamTransformer<String, String> _validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (!ValidatorUtils.validEmail(email)) {
      sink.addError('Email is invalid.');
    } else {
      sink.add(email);
    }
  });

  StreamTransformer<String, String> _validPassword =
      StreamTransformer<String, String>.fromHandlers(
          handleData: (password, sink) {
    if (password.isEmpty) {
      sink.addError('Input password');
    } else {
      sink.add(password);
    }
  });

  void dispose() async {
    await _userEmailController.drain();
    _userEmailController?.close();
    await _userPasswordController.drain();
    _userPasswordController?.close();
    await _loginStreamController.drain();
    _loginStreamController?.close();
    await _imageStreamLoginController.drain();
    _imageStreamLoginController?.close();
  }

  //Stream
  Observable<String> get imageStream => _imageStreamLoginController.stream;

  Observable<String> get emailStream =>
      _userEmailController.stream.transform(_validateEmail);

  Observable<String> get passwordStream =>
      _userPasswordController.stream.transform(_validPassword);

  Observable<bool> get loginStream => _loginStreamController.stream;

//  Observable<bool> get loginStream => Observable.combineLatest2(emailStream, passwordStream, (e,p) => true);

  Function(bool) get doLoginStream => _loginStreamController.sink.add;

  //add input
  Function(String) get emailStreamChange => _userEmailController.sink.add;

  Function(String) get passwordStreamChange => _userPasswordController.sink.add;

  Future<User> authenticateUser() {
    var email = _userEmailController.value;
    var password = _userPasswordController.value;
    return _repository.authenticateUser(email, password);
  }
}
