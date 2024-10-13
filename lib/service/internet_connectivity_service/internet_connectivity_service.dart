import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectuser/service/internet_connectivity_service/iinternet_connectivity_service.dart';
import 'package:connectuser/utils/extensions.dart';

class InternetConnectivityService extends IInternetConnectivityService {
  @override
  Future<bool> getNetworkConnectivityStatus() async {
    try {
            final List<ConnectivityResult> connectivityResult =
          await (Connectivity().checkConnectivity());

      return
          !connectivityResult.contains(ConnectivityResult.none);
    } catch (ex) {
      ex.logError();
      return false;
    }
  }
}
