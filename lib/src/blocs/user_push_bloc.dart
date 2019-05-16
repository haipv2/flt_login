import 'package:flt_login/src/resources/repository.dart';

class UserPushBloc {
  final _repository = Repository();

  Future<List<dynamic>> getListPushIdViaLoginId(String loginId) async{
    var result = await _repository.getListPushIdViaLoginId(loginId);
    return result;
  }
}
