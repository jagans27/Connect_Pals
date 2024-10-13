import 'package:connectuser/model/user.dart';
import 'package:connectuser/utils/constants.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:connectuser/service/api_service/ai_service/iai_service.dart';
import 'package:connectuser/service/internet_connectivity_service/iinternet_connectivity_service.dart';
import 'package:connectuser/utils/service_result.dart';
import 'package:connectuser/widgets/snackbar_helper.dart';

class AIProvider extends ChangeNotifier {
  final IAIService aiService;
  final IInternetConnectivityService internetConnectivityService;

  List<User>? matchings;
  bool isLoading = false;

  AIProvider({
    required this.aiService,
    required this.internetConnectivityService,
  });

  Future<void> getMatchings({required String email}) async {
    try {
      isLoading = true;
      notifyListeners();

      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        ServiceResult<List<User>> result =
            await aiService.getMatchings(email: email);

        if (result.status == Status.success) {
          matchings = result.data;
        } else {
          SnackbarHelper.showSnackbar(result.message);
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
      }
    } catch (ex) {
      ex.logError();
      SnackbarHelper.showSnackbar('Error: ${ex.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateFriendshipStatus(
      {required int index, required FriendRequestStatus friendRequestStatus}) {
    try {
      if (friendRequestStatus == FriendRequestStatus.pending) {
        matchings![index].friendshipStatus = FriendRequestStatus.friends.name;
      } else if (friendRequestStatus == FriendRequestStatus.none) {
        matchings![index].friendshipStatus = FriendRequestStatus.request.name;
      }
      notifyListeners();
    } catch (ex) {
      ex.logError();
    }
  }
}
