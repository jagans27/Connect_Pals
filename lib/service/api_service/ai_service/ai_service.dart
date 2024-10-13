import 'package:connectuser/model/user.dart';
import 'package:connectuser/service/api_service/ai_service/iai_service.dart';
import 'package:connectuser/utils/constants.dart';
import 'package:connectuser/utils/service_result.dart';
import 'package:dio/dio.dart';

class AiService extends IAIService {
  final Dio _dio;

  AiService() : _dio = Dio(BaseOptions(
    baseUrl: Constants.apiBaseUrl, // Set your base URL here
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  @override
  Future<ServiceResult<List<User>>> getMatchings({required String email}) async {
    try {
      print("===> $email");

      // Make sure to use POST instead of GET for sending data
      Response response = await _dio.post(
        '/similarity',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        List<User> users = (response.data['data'] as List).map((item) {
          return User.fromJson(item['user']);
        }).toList();

        return ServiceResult<List<User>>(
          status: Status.success,
          data: users,
          message: response.data['message'] ?? 'Fetched successfully',
        );
      } else {
        return ServiceResult<List<User>>(
          status: Status.failure,
          data: null,
          message: response.data['message'] ?? 'Unknown error',
        );
      }
    } on DioException catch (error) {
      print(error.message);

      print("==>${error.response}");
      
      if (error.response != null) {
        return ServiceResult<List<User>>(
          status: Status.failure,
          data: null,
          message: error.response?.data['message'] ?? 'Unknown error',
        );
      } else {
        return ServiceResult<List<User>>(
          status: Status.failure,
          data: null,
          message: 'Network error: ${error.message}',
        );
      }
    } catch (ex) {
      print(ex.toString());

      return ServiceResult<List<User>>(
        status: Status.failure,
        data: null,
        message: 'Error: ${ex.toString()}',
      );
    }
  }
}
