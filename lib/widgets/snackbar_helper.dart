import 'package:connectuser/utils/extensions.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  static GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showSnackbar(String message) {
    try {
      scaffoldMessengerKey.currentState
        ?..clearSnackBars()
        ..showSnackBar(SnackBar(
          duration: const Duration(seconds: 3),
          content: Text(message,
              style: const TextStyle(fontSize: 15, color: Colors.black)),
          backgroundColor: const Color(0xffede0d4),
        ));
    } catch (ex) {
      ex.logError();
    }
  }
}
