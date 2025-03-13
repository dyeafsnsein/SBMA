import 'package:flutter/material.dart';
import '../Models/login_model.dart';

class LoginController extends ChangeNotifier {
  final LoginModel model;

  LoginController(this.model);

  bool get isPasswordVisible => model.isPasswordVisible;
  String get email => model.email;
  String get password => model.password;

  void togglePasswordVisibility() {
    model.isPasswordVisible = !model.isPasswordVisible;
    notifyListeners();
  }

  void setEmail(String email) {
    model.email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    model.password = password;
    notifyListeners();
  }
}