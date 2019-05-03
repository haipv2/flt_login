import 'dart:async';

import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/resources/repository.dart';
import 'package:flt_login/src/utils/validator_utils.dart';
import 'package:rxdart/rxdart.dart';

class SignupBloc extends Object {
  final _repository = Repository();
  final _firstNameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _userEmailController = BehaviorSubject<String>();
  final _userPasswordController = BehaviorSubject<String>();
  final _confirmPasswordController = BehaviorSubject<String>();
  final _genderStreamController = BehaviorSubject<int>();
  final _userphone = BehaviorSubject<String>();
  final _userRole = BehaviorSubject<String>();
  final _isSignedIn = BehaviorSubject<bool>();
  final _progressBarController = BehaviorSubject<bool>();
  final _resetFormStreamController = PublishSubject();

  String get email => _userEmailController.value;

  Observable get resetFormStream => _resetFormStreamController.stream;

  final _validateName =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (!ValidatorUtils.validString(name) ||
        !ValidatorUtils.checkLength(name, 10, 3)) {
      sink.addError('This is required and contain 3 characters at least.');
    } else {
      sink.add(name);
    }
  });

  final _validatePass =
      StreamTransformer<String, String>.fromHandlers(handleData: (name, sink) {
    if (!ValidatorUtils.validString(name) ||
        !ValidatorUtils.checkLength(name, 13, 7)) {
      sink.addError('This is required and contain from 6-12 characters.');
    } else {
      sink.add(name);
    }
  });

  final _validatePassConfirm = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password == null) {
      sink.addError('password is required');
    } else {
      sink.add(password);
    }
  });

  final _validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (!ValidatorUtils.validEmail(email)) {
      sink.addError('Email is invalid.');
    } else {
      sink.add(email);
    }
  });

  // Streams
  Observable<int> get genderStream => _genderStreamController.stream;

  Observable<String> get firstNameStream =>
      _firstNameController.stream.transform(_validateName);

  Observable<String> get lastNameStream =>
      _lastNameController.stream.transform(_validateName);

  Observable<String> get userEmailStream =>
      _userEmailController.stream.transform(_validateEmail);

  Observable<String> get passwordStream => _userPasswordController.stream
          .transform(_validatePass)
          .doOnData((String s) {
        print(s);
        if (0 != _confirmPasswordController.value.compareTo(s)) {
          _confirmPasswordController.sink.add('');
          _confirmPasswordController.sink.addError('Password does not match.');
        }
        ;
      });

  Observable<String> get passwordConfirmStream =>
      _confirmPasswordController.stream
          .transform(_validatePassConfirm)
          .doOnData((String c) {
        if (0 != _userPasswordController.value.compareTo(c)) {
          _confirmPasswordController.addError('Password does not match.');
        }
      });

  Observable<bool> get progressBarStream => _progressBarController.stream;

  //change data
  Function(String) get changeFirstName => _firstNameController.sink.add;

  Function(String) get changeLastName => _lastNameController.sink.add;

  Function(String) get changeEmail => _userEmailController.sink.add;

  Function(String) get changePass => _userPasswordController.sink.add;

  Function(String) get changePassConfirm => _confirmPasswordController.sink.add;

  Function(int) get changeGenderStream => _genderStreamController.sink.add;

  Function(bool) get showProgressBar => _progressBarController.sink.add;

  //register button
  Stream<bool> get registerStream => Observable.combineLatest5(
      firstNameStream,
      lastNameStream,
      userEmailStream,
      passwordStream,
      passwordConfirmStream,
      (firstName, lastname, email, pass, confirmPass) => true);

  void dispose() async {
    await _firstNameController.drain();
    _firstNameController?.close();
    _confirmPasswordController?.close();
    _lastNameController?.close();
    _userPasswordController?.close();
    _userEmailController?.close();
    _genderStreamController?.close();
  }

  Future<User> register() {
    User user = User();
    user.firstname = _firstNameController.value;
    user.lastname = _lastNameController.value;
    user.email = _userEmailController.value;
    user.password = _userPasswordController.value;
    user.gender = _genderStreamController.value == null ? 1: 0;
    return _repository.registerUser(user);
  }
}
