

class UserPushInfo {
  String _email;
  String _pushId;

  UserPushInfo(this._email, this._pushId);

  Map<String,dynamic> toJson() => {
    'email':email,
    'push_id':pushId,
  };

  UserPushInfo.fromJson(Map<String,dynamic> map){
    email=map['email'];
    pushId=map['pushId'];
  }

  String get pushId => _pushId;

  set pushId(String value) {
    _pushId = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }


}