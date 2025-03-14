import 'package:flutter/material.dart';
import '../Models/signup_model.dart';

class SignupController extends ChangeNotifier {
  final SignupModel model;

  SignupController(this.model);

  String get fullName => model.fullName;
  String get email => model.email;
  String get mobileNumber => model.mobileNumber;
  String get dateOfBirth => model.dateOfBirth;
  String get password => model.password;
  String get confirmPassword => model.confirmPassword;

  void setFullName(String value) {
    model.fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    model.email = value;
    notifyListeners();
  }

  void setMobileNumber(String value) {
    model.mobileNumber = value;
    notifyListeners();
  }

  void setDateOfBirth(String value) {
    model.dateOfBirth = value;
    notifyListeners();
  }

  void setPassword(String value) {
    model.password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    model.confirmPassword = value;
    notifyListeners();
  }
}