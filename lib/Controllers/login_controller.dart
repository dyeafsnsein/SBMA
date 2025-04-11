import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../Models/login_model.dart';

class LoginController extends ChangeNotifier {
  final LoginModel model;
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LoginController(this.model) {
    emailController.text = model.email;
    passwordController.text = model.password;

    emailController.addListener(() {
      model.email = emailController.text;
    });
    passwordController.addListener(() {
      model.password = passwordController.text;
    });
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      _errorMessage = 'Please fill in all required fields';
      notifyListeners();
      return;
    }

    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailPattern.hasMatch(emailController.text.trim())) {
      _errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      if (e.toString().contains('Google Sign-In canceled')) {
        _errorMessage = 'Google login was canceled.';
      } else {
        _errorMessage = 'Google login failed: ${e.toString()}';
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}