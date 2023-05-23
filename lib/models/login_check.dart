import 'package:flutter/material.dart';

class LoginCheck extends ChangeNotifier {
  bool isLoggedIn = false;

  void changeLog() {
    isLoggedIn = !isLoggedIn;
    notifyListeners();
  }
}
