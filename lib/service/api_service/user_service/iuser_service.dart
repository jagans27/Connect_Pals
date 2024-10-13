import 'package:connectuser/model/user.dart';
import 'package:connectuser/utils/service_result.dart';

abstract class IUserService {
  Future<ServiceResult<User>> login(User user);
  Future<ServiceResult<User>> signUp(User user);
  Future<ServiceResult<User>> update(User user);

  Future<ServiceResult<void>> sendFriendRequest(
      {required String requesterEmail, required String recipientEmail});
  Future<ServiceResult<void>> acceptFriendRequest(
      {required String requesterEmail, required String recipientEmail});
  Future<ServiceResult<void>> rejectFriendRequest(
      {required String requesterEmail, required String recipientEmail});
  Future<ServiceResult<void>> deleteFriend(
      {required String requesterEmail, required String recipientEmail}) ;
  Future<ServiceResult<List<User>>> getFriendsList(String email);
    Future<ServiceResult<List<User>>> searchUsers({required String query,required String email});

}
