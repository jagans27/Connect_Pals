import 'package:connectuser/screens/login_screen.dart';
import 'package:connectuser/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Connect Pals',
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: SnackbarHelper.scaffoldMessengerKey,
        home: const LoginScreen());
  }
}
