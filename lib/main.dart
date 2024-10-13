import 'package:connectuser/app.dart';
import 'package:connectuser/provider/ai_provider.dart';
import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/provider/user_provider.dart';
import 'package:connectuser/service/api_service/ai_service/ai_service.dart';
import 'package:connectuser/service/api_service/ai_service/iai_service.dart';
import 'package:connectuser/service/internet_connectivity_service/iinternet_connectivity_service.dart';
import 'package:connectuser/service/internet_connectivity_service/internet_connectivity_service.dart';
import 'package:connectuser/service/api_service/user_service/iuser_service.dart';
import 'package:connectuser/service/api_service/user_service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I.registerSingleton<IInternetConnectivityService>(
      InternetConnectivityService());
  GetIt.I.registerSingleton<IUserService>(UserService());
  GetIt.I.registerSingleton<IAIService>(AiService());

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
        create: (context) => LoginProvider(
              internetConnectivityService:
                  GetIt.I.get<IInternetConnectivityService>(),
              userService: GetIt.I.get<IUserService>(),
            )),
    ChangeNotifierProvider(
        create: (context) => UserProvider(
              internetConnectivityService:
                  GetIt.I.get<IInternetConnectivityService>(),
              userService: GetIt.I.get<IUserService>(),
            )),
    ChangeNotifierProvider(
      create: (context) => AIProvider(
          aiService: GetIt.I.get<IAIService>(),
          internetConnectivityService:
              GetIt.I.get<IInternetConnectivityService>()),
    )
  ], child: const App()));
}
