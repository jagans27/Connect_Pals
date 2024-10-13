import 'package:connectuser/model/user.dart';
import 'package:connectuser/service/api_service/user_service/iuser_service.dart';
import 'package:connectuser/utils/service_result.dart';
import 'package:dio/dio.dart';
import 'package:connectuser/utils/constants.dart';

class UserService extends IUserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Constants.apiBaseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  @override
  Future<ServiceResult<User>> login(User user) async {
    try {
      final response = await _dio.post(
        '/users/login',
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        final userData = User.fromJson(response.data['data']);

        return ServiceResult<User>(
          status: Status.success,
          data: userData,
          message: 'Login successful',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      if (error.response != null) {
        return ServiceResult<User>(
          status: Status.failure,
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: 'Network error: ${error.message}',
        );
      }
    } catch (ex) {
      return ServiceResult<User>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  @override
  Future<ServiceResult<User>> signUp(User user) async {
    try {
      final response = await _dio.post(
        '/users/signup',
        data: user.toJson(),
      );

      if (response.statusCode == 201) {
        final userData = User.fromJson(response.data['data']);
        return ServiceResult<User>(
          status: Status.success,
          data: userData,
          message: 'Sign up successful',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      if (error.response != null) {
        return ServiceResult<User>(
          status: Status.failure,
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: 'Network error: ${error.message}',
        );
      }
    } catch (ex) {
      return ServiceResult<User>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  @override
  Future<ServiceResult<User>> update(User user) async {
    try {
      final response = await _dio.put(
        '/users/update',
        data: user.toJson(),
      );

      if (response.statusCode == 200) {
        final userData = User.fromJson(response.data['data']);
        return ServiceResult<User>(
          status: Status.success,
          data: userData,
          message: 'Update successful',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      if (error.response != null) {
        return ServiceResult<User>(
          status: Status.failure,
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      } else {
        return ServiceResult<User>(
          status: Status.failure,
          message: 'Network error: ${error.message}',
        );
      }
    } catch (ex) {
      return ServiceResult<User>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  // Send friend request
  @override
  Future<ServiceResult<void>> sendFriendRequest(
      {required String requesterEmail, required String recipientEmail}) async {
    try {
      final response = await _dio.post(
        '/friends/request',
        data: {
          'requester_email': requesterEmail,
          'recipient_email': recipientEmail,
        },
      );

      if (response.statusCode == 201) {
        return ServiceResult<void>(
          status: Status.success,
          message: 'Friend request sent successfully',
        );
      } else {
        return ServiceResult<void>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      return ServiceResult<void>(
        status: Status.failure,
        message: error.response?.data['message'] ??
            'Network error: ${error.message}',
      );
    } catch (ex) {
      return ServiceResult<void>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  // Accept friend request
  @override
  Future<ServiceResult<void>> acceptFriendRequest(
      {required String requesterEmail, required String recipientEmail}) async {
    try {
      final response = await _dio.post(
        '/friends/accept',
        data: {
          'requester_email': requesterEmail,
          'recipient_email': recipientEmail,
        },
      );

      if (response.statusCode == 200) {
        return ServiceResult<void>(
          status: Status.success,
          message: 'Friend request accepted successfully',
        );
      } else {
        return ServiceResult<void>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      return ServiceResult<void>(
        status: Status.failure,
        message: error.response?.data['message'] ??
            'Network error: ${error.message}',
      );
    } catch (ex) {
      return ServiceResult<void>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  // Reject friend request
  @override
  Future<ServiceResult<void>> rejectFriendRequest(
      {required String requesterEmail, required String recipientEmail}) async {
    try {
      final response = await _dio.post(
        '/friends/reject',
        data: {
          'requester_email': requesterEmail,
          'recipient_email': recipientEmail,
        },
      );

      if (response.statusCode == 200) {
        return ServiceResult<void>(
          status: Status.success,
          message: 'Friend request rejected successfully',
        );
      } else {
        return ServiceResult<void>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      return ServiceResult<void>(
        status: Status.failure,
        message: error.response?.data['message'] ??
            'Network error: ${error.message}',
      );
    } catch (ex) {
      return ServiceResult<void>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  // Delete friend
  @override
  Future<ServiceResult<void>> deleteFriend(
      {required String requesterEmail, required String recipientEmail}) async {
    try {
      final response = await _dio.post(
        '/friends/delete',
        data: {
          'requester_email': requesterEmail,
          'recipient_email': recipientEmail,
        },
      );

      if (response.statusCode == 200) {
        return ServiceResult<void>(
          status: Status.success,
          message: 'Friendship deleted successfully',
        );
      } else {
        return ServiceResult<void>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      return ServiceResult<void>(
        status: Status.failure,
        message: error.response?.data['message'] ??
            'Network error: ${error.message}',
      );
    } catch (ex) {
      return ServiceResult<void>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  // Get friends list
  @override
  Future<ServiceResult<List<User>>> getFriendsList(String email) async {
    try {
      final response = await _dio.post(
        '/friends/list',
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        List<User> friends = (response.data['data'] as List)
            .map((friend) => User.fromJson(friend))
            .toList();

        return ServiceResult<List<User>>(
          status: Status.success,
          data: friends,
          message: 'Friends list retrieved successfully',
        );
      } else {
        return ServiceResult<List<User>>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      return ServiceResult<List<User>>(
        status: Status.failure,
        message: error.response?.data['message'] ??
            'Network error: ${error.message}',
      );
    } catch (ex) {
      return ServiceResult<List<User>>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }

  @override
  Future<ServiceResult<List<User>>> searchUsers(
      {required String query, required String email}) async {
    try {
      final response = await _dio.post(
        '/users/search',
        data: {'query': query, 'email': email},
      );

      if (response.statusCode == 200) {
        final List<User> usersData = (response.data['data'] as List)
            .map((user) => User.fromJson(user))
            .toList();
        return ServiceResult<List<User>>(
          status: Status.success,
          data: usersData,
          message: 'Search successful',
        );
      } else {
        return ServiceResult<List<User>>(
          status: Status.failure,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      if (error.response != null) {
        return ServiceResult<List<User>>(
          status: Status.failure,
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      } else {
        return ServiceResult<List<User>>(
          status: Status.failure,
          message: 'Network error: ${error.message}',
        );
      }
    } catch (ex) {
      return ServiceResult<List<User>>(
        status: Status.failure,
        message: 'Error: ${ex.toString()}',
      );
    }
  }
}
