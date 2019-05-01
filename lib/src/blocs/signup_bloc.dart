import 'dart:async';

import 'package:flt_login/src/resources/repository.dart';
import 'package:flt_login/src/utils/validator_utils.dart';
import 'package:rxdart/rxdart.dart';

class SignupBloc {
  final _repository = Repository();
  final _firstName = BehaviorSubject<String>();
  final _lastName = BehaviorSubject<String>();
  final _username = BehaviorSubject<String>();
  final _userphone = BehaviorSubject<String>();
  final _userRole = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _isSignedIn = BehaviorSubject<bool>();

  StreamTransformer<String, String> _validateName =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (!ValidatorUtils.validString(name) ||
        !ValidatorUtils.checkLength(name, 10,3)) {
      sink.addError('This is require and has at least 3 characters');
    } else {
      sink.add(name);
    }
  });

  Observable<String> get firstNameStream =>
      _firstName.stream.transform(_validateName);

  Observable<String> get lastNameStream =>
      _lastName.stream;

  Observable<String> get userNameStream =>
      _username.stream;

  void dispose() async{
    await _firstName.drain();
    _firstName.close();

  }
}
