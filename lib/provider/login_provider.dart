import 'package:connectuser/model/user.dart';
import 'package:connectuser/service/internet_connectivity_service/iinternet_connectivity_service.dart';
import 'package:connectuser/service/api_service/user_service/iuser_service.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:connectuser/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:connectuser/utils/service_result.dart';

class LoginProvider extends ChangeNotifier {
  bool isLogin = true;
  final IInternetConnectivityService internetConnectivityService;
  final IUserService userService;
  late User userData;

  LoginProvider({
    required this.internetConnectivityService,
    required this.userService,
  });

  void toggleForm() {
    isLogin = !isLogin;
    notifyListeners();
  }

  Future<User?> login({required User user}) async {
    try {
      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        ServiceResult<User> result = await userService.login(user);

        if (result.status == Status.success) {
          userData = result.data!;
          return result.data;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return null;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return null;
      }
    } catch (ex) {
      ex.logError();
      return null;
    }
  }

  Future<bool> signUp({required User user}) async {
    try {
      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        final result = await userService.signUp(user);
        if (result.status == Status.success) {
          userData = result.data!;
          return true;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return false;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return false;
      }
    } catch (ex) {
      ex.logError();
      return false;
    }
  }

  Future<bool> updateDetails({required User user}) async {
    try {
      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        final result = await userService.update(user);
        if (result.status == Status.success) {
          userData = result.data!;
          return true;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return false;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return false;
      }
    } catch (ex) {
      ex.logError();
      return false;
    }
  }
}
