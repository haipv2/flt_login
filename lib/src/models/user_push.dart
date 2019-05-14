

class UserPushInfo {
  String _email;
  String _token;
  String _pushId;

  UserPushInfo(this._email, this._token, this._pushId);

  String get pushId => _pushId;

  set pushId(String value) {
    _pushId = value;
  }

  String get token => _token;

  set token(String value) {
    _token = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }


}