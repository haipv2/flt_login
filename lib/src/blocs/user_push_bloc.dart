import 'package:flt_login/src/resources/repository.dart';

class UserPushBloc {
  final _repository = Repository();

  List<String> getListPushIdViaEmail(String email) {
    var result = _repository.getListPushIdViaEmail(email);
    print('repository print');

    return result;
  }
}
