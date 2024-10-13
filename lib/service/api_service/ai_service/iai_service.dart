import 'package:connectuser/model/user.dart';
import 'package:connectuser/utils/service_result.dart';

abstract class IAIService {
  Future<ServiceResult<List<User>>> getMatchings({required String email});
}
