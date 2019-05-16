import 'package:flt_login/src/resources/repository.dart';

class UserPushBloc {
  final _repository = Repository();

  Future<List<String>> getListPushIdViaEmail(String email) async{
    var result = await _repository.getListPushIdViaEmail(email);

    return result;
  }
}
