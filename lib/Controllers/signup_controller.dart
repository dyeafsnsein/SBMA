import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../Models/signup_model.dart';

class SignupController extends ChangeNotifier {
  final SignupModel model;
  final AuthService _authService = AuthService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SignupController(this.model) {
    nameController.text = model.name;
    emailController.text = model.email;
    passwordController.text = model.password;
    confirmPasswordController.text = model.confirmPassword;
    dateOfBirthController.text = model.dateOfBirth;
    mobileNumberController.text = model.mobileNumber;

    nameController.addListener(() {
      model.name = nameController.text;
    });
    emailController.addListener(() {
      model.email = emailController.text;
    });
    passwordController.addListener(() {
      model.password = passwordController.text;
    });
    confirmPasswordController.addListener(() {
      model.confirmPassword = confirmPasswordController.text;
    });
    dateOfBirthController.addListener(() {
      model.dateOfBirth = dateOfBirthController.text;
    });
    mobileNumberController.addListener(() {
      model.mobileNumber = mobileNumberController.text;
    });
  }

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    // Basic validation
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty ||
        dateOfBirthController.text.trim().isEmpty ||
        mobileNumberController.text.trim().isEmpty) {
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

    if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return;
    }

    if (passwordController.text.trim().length < 6) {
      _errorMessage = 'Password must be at least 6 characters long';
      notifyListeners();
      return;
    }

    // Validate date of birth format (e.g., DD/MM/YYYY)
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!datePattern.hasMatch(dateOfBirthController.text.trim())) {
      _errorMessage = 'Please enter a valid date of birth (DD/MM/YYYY)';
      notifyListeners();
      return;
    }

    // Validate mobile number (e.g., 8 digits for a simple check)
    final mobilePattern = RegExp(r'^\d{8}$');
    if (!mobilePattern.hasMatch(mobileNumberController.text.trim())) {
      _errorMessage = 'Please enter a valid mobile number (8 digits)';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        dateOfBirth: dateOfBirthController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
      );
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dateOfBirthController.dispose();
    mobileNumberController.dispose();
    super.dispose();
  }
}