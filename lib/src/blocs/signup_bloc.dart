import 'dart:async';

import 'package:flt_login/src/resources/repository.dart';
import 'package:flt_login/src/utils/validator_utils.dart';
import 'package:rxdart/rxdart.dart';

class SignupBloc extends Object {
  final _repository = Repository();
  final _firstNameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _userEmailController = BehaviorSubject<String>();
  final _userphone = BehaviorSubject<String>();
  final _userRole = BehaviorSubject<String>();
  final _userPasswordController = BehaviorSubject<String>();
  final _confirmPasswordController = BehaviorSubject<String>();
  final _isSignedIn = BehaviorSubject<bool>();
  final _genderStreamController = BehaviorSubject<bool>();

  final _validateName =
      StreamTransformer < String,
      String

  >

      .

  fromHandlers

  (

  handleData

      :

  (

  name

  ,

  sink

  )

  {
  if (!ValidatorUtils.validString(name) ||
  !ValidatorUtils.checkLength(name, 10, 3)) {
  sink.addError('This is required and contain 3 characters at least.');
  } else {
  sink.add(name);
  }
  }

  );

  final _validatePass =
      StreamTransformer < String,
      String

  >

      .

  fromHandlers

  (

  handleData

      :

  (

  name

  ,

  sink

  )

  {
  if (!ValidatorUtils.validString(name) ||
  !ValidatorUtils.checkLength(name, 13, 7)) {
  sink.addError('This is required and contain from 6-12 characters.');
  } else {
  sink.add(name);
  }
  }

  );

  final _validatePassConfirm = StreamTransformer < String,
      String

  >

      .

  fromHandlers

  (

  handleData

      :

  (

  password

  ,

  sink

  )

  {
  if (password == null) {
  sink.addError('password is required');
  } else {
  sink.add(password);
  }
  }

  );

  final _validateEmail =
      StreamTransformer < String,
      String

  >

      .

  fromHandlers

  (

  handleData

      :

  (

  email

  ,

  sink

  )

  {
  if (!ValidatorUtils.validEmail(email)) {
  sink.addError('Email is invalid.');
  } else {
  sink.add(email);
  }
  }

  );

  //change data
  Function(String) get changeFirstName => _firstNameController.sink.add;

  Function(String) get changeLastName => _lastNameController.sink.add;

  Function(String) get changeEmail => _userEmailController.sink.add;

  Function(String) get changePass => _userPasswordController.sink.add;

  Function(String) get changePassConfirm => _confirmPasswordController.sink.add;

  Function(bool) get changeGenderStream => _genderStreamController.sink.add;

  //register button
  Stream<bool> get registerStream =>
      Observable.combineLatest5(
          firstNameStream,
          lastNameStream,
          userEmailStream,
          passwordStream,
          passwordConfirmStream,
              (firstName, lastname, email, pass, confirmPass) => true
      );

  // Streams
  Observable<bool> get genderStream => _genderStreamController.stream;

  Observable<String> get firstNameStream =>
      _firstNameController.stream.transform(_validateName);

  Observable<String> get lastNameStream =>
      _lastNameController.stream.transform(_validateName);

  Observable<String> get userEmailStream =>
      _userEmailController.stream.transform(_validateEmail);

  Observable<String> get passwordStream =>
      _userPasswordController.stream
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

  void dispose() async {
    _firstNameController?.close();
    _confirmPasswordController?.close();
    _lastNameController?.close();
    _userPasswordController?.close();
    _userEmailController?.close();
  }

  bool validateFields() {
    if (!ValidatorUtils.validString(_firstNameController.value) ||
        !ValidatorUtils.checkLength(_firstNameController.value, 10, 3)) {
      return false;
    } else {
      return true;
    }
  }
}
