import 'package:flt_login/src/models/user.dart';
import 'package:flt_login/src/resources/repository.dart';

class MyPageBloc {
  final _repository = Repository();
  Future<void> getUserViaLoginId(String loginId, User player) async {
    var user = await _repository.getUserViaLoginId(loginId);
    player = user;
  }
}