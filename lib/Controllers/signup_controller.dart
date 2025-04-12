import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class SignupController extends ChangeNotifier {
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
  String? _nameErrorMessage;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _confirmPasswordErrorMessage;
  String? _dateOfBirthErrorMessage;
  String? _mobileNumberErrorMessage;

  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get nameErrorMessage => _nameErrorMessage;
  String? get emailErrorMessage => _emailErrorMessage;
  String? get passwordErrorMessage => _passwordErrorMessage;
  String? get confirmPasswordErrorMessage => _confirmPasswordErrorMessage;
  String? get dateOfBirthErrorMessage => _dateOfBirthErrorMessage;
  String? get mobileNumberErrorMessage => _mobileNumberErrorMessage;

  SignupController() {
    // Add listeners for real-time validation
    nameController.addListener(_validateNameRealTime);
    emailController.addListener(_validateEmailRealTime);
    passwordController.addListener(_validatePasswordRealTime);
    confirmPasswordController.addListener(_validateConfirmPasswordRealTime);
    dateOfBirthController.addListener(_validateDateOfBirthRealTime);
    mobileNumberController.addListener(_validateMobileNumberRealTime);
  }

  void _validateNameRealTime() {
    final namePattern = RegExp(r'^[a-zA-Z\s]+$');
    if (nameController.text.trim().isEmpty) {
      _nameErrorMessage = 'Full name is required';
    } else if (!namePattern.hasMatch(nameController.text.trim())) {
      _nameErrorMessage = 'Full name should contain only alphabets and spaces';
    } else {
      _nameErrorMessage = null;
    }
    notifyListeners();
  }

  void _validateEmailRealTime() {
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (emailController.text.trim().isEmpty) {
      _emailErrorMessage = 'Email is required';
    } else if (!emailPattern.hasMatch(emailController.text.trim())) {
      _emailErrorMessage = 'Please enter a valid email (e.g., test@test.test)';
    } else {
      _emailErrorMessage = null;
    }
    notifyListeners();
  }

  void _validatePasswordRealTime() {
    final passwordPattern = RegExp(r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$%^&*]).{6,}$');
    if (passwordController.text.trim().isEmpty) {
      _passwordErrorMessage = 'Password is required';
    } else if (!passwordPattern.hasMatch(passwordController.text.trim())) {
      _passwordErrorMessage =
          'Password must contain at least one number, one uppercase letter, one lowercase letter, and one special character';
    } else {
      _passwordErrorMessage = null;
    }
    notifyListeners();
  }

  void _validateConfirmPasswordRealTime() {
    if (confirmPasswordController.text.trim().isEmpty) {
      _confirmPasswordErrorMessage = 'Confirm password is required';
    } else if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      _confirmPasswordErrorMessage = 'Passwords do not match';
    } else {
      _confirmPasswordErrorMessage = null;
    }
    notifyListeners();
  }

  void _validateDateOfBirthRealTime() {
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (dateOfBirthController.text.trim().isEmpty) {
      _dateOfBirthErrorMessage = 'Date of birth is required';
    } else if (!datePattern.hasMatch(dateOfBirthController.text.trim())) {
      _dateOfBirthErrorMessage = 'Please enter a valid date of birth (DD/MM/YYYY)';
    } else {
      final dobParts = dateOfBirthController.text.trim().split('/');
      final dob = DateTime(
        int.parse(dobParts[2]), // Year
        int.parse(dobParts[1]), // Month
        int.parse(dobParts[0]), // Day
      );
      final currentDate = DateTime(2025, 4, 12); // Current date
      final age = currentDate.difference(dob).inDays ~/ 365;
      if (age < 18) {
        _dateOfBirthErrorMessage = 'You must be at least 18 years old';
      } else {
        _dateOfBirthErrorMessage = null;
      }
    }
    notifyListeners();
  }

  void _validateMobileNumberRealTime() {
    final mobilePattern = RegExp(r'^\+216\d{8}$');
    if (mobileNumberController.text.trim().isEmpty) {
      _mobileNumberErrorMessage = 'Mobile number is required';
    } else if (!mobilePattern.hasMatch(mobileNumberController.text.trim())) {
      _mobileNumberErrorMessage = 'Please enter a valid Tunisian mobile number (e.g., +21612345678)';
    } else {
      _mobileNumberErrorMessage = null;
    }
    notifyListeners();
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
    _errorMessage = null;
    notifyListeners();

    // Check if there are any real-time errors
    if (_nameErrorMessage != null ||
        _emailErrorMessage != null ||
        _passwordErrorMessage != null ||
        _confirmPasswordErrorMessage != null ||
        _dateOfBirthErrorMessage != null ||
        _mobileNumberErrorMessage != null) {
      _errorMessage = 'Please fix the errors in the form';
      notifyListeners();
      return;
    }

    // Proceed with signup if all validations pass
    _isLoading = true;
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
    _nameErrorMessage = null;
    _emailErrorMessage = null;
    _passwordErrorMessage = null;
    _confirmPasswordErrorMessage = null;
    _dateOfBirthErrorMessage = null;
    _mobileNumberErrorMessage = null;
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