
import 'package:flt_login/src/resources/repository.dart';

class UserPushBloc {
  final _repository = Repository();

  Future<List<String>> getListPushIdViaEmail(String email) {
    return _repository.getListPushIdViaEmail(email);
  }}
