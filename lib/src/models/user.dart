class User {
  String _firstname;
  String _lastname;
  String _email;
  String _password;
  String _role;
  int _gender;

  int get gender => _gender;

  User();

  User.fromJson(Map<String, dynamic> json) {
    firstname = json['first_name'];
    email = json['email'];
    lastname = json['last_name'];
    gender = json['gender'];
//    email=json['email'];
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstname,
        'last_name': lastname,
        'gender': gender,
      };

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
