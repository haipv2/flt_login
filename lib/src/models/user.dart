class User{
  String _firstname;
  String _lastname;
  String _email;
  String _password;
  String _role;
  int _gender;

  int get gender => _gender;

  set gender(int value) {
    _gender = value;
  }

  String get firstname => _firstname;

  set firstname(String value) {
    _firstname = value;
  }

  String get lastname => _lastname;

  String get role => _role;

  set role(String value) {
    _role = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  set lastname(String value) {
    _lastname = value;
  }


}