import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/user_model.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  UserModel userModel = UserModel();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage;
  String? nameErrorMessage;
  String? emailErrorMessage;
  String? passwordErrorMessage;
  String? confirmPasswordErrorMessage;
  String? dateOfBirthErrorMessage;
  String? mobileNumberErrorMessage;

  // TextEditingControllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  AuthController() {
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
      nameErrorMessage = 'Full name is required';
    } else if (!namePattern.hasMatch(nameController.text.trim())) {
      nameErrorMessage = 'Full name should contain only alphabets and spaces';
    } else {
      nameErrorMessage = null;
    }
    notifyListeners();
  }

  void _validateEmailRealTime() {
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (emailController.text.trim().isEmpty) {
      emailErrorMessage = 'Email is required';
    } else if (!emailPattern.hasMatch(emailController.text.trim())) {
      emailErrorMessage = 'Please enter a valid email (e.g., test@test.test)';
    } else {
      emailErrorMessage = null;
    }
    notifyListeners();
  }

  void _validatePasswordRealTime() {
    final passwordPattern = RegExp(r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$%^&*]).{6,}$');
    if (passwordController.text.trim().isEmpty) {
      passwordErrorMessage = 'Password is required';
    } else if (!passwordPattern.hasMatch(passwordController.text.trim())) {
      passwordErrorMessage =
          'Password must contain at least one number, one uppercase letter, one lowercase letter, and one special character';
    } else {
      passwordErrorMessage = null;
    }
    _validateConfirmPasswordRealTime(); // Re-validate confirm password if password changes
    notifyListeners();
  }

  void _validateConfirmPasswordRealTime() {
    if (confirmPasswordController.text.trim().isEmpty) {
      confirmPasswordErrorMessage = 'Confirm password is required';
    } else if (passwordController.text.trim() != confirmPasswordController.text.trim()) {
      confirmPasswordErrorMessage = 'Passwords do not match';
    } else {
      confirmPasswordErrorMessage = null;
    }
    notifyListeners();
  }

  void _validateDateOfBirthRealTime() {
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (dateOfBirthController.text.trim().isEmpty) {
      dateOfBirthErrorMessage = 'Date of birth is required';
    } else if (!datePattern.hasMatch(dateOfBirthController.text.trim())) {
      dateOfBirthErrorMessage = 'Please enter a valid date of birth (DD/MM/YYYY)';
    } else {
      final dobParts = dateOfBirthController.text.trim().split('/');
      final dob = DateTime(
        int.parse(dobParts[2]), // Year
        int.parse(dobParts[1]), // Month
        int.parse(dobParts[0]), // Day
      );
      final currentDate = DateTime(2025, 4, 17); // Current date
      final age = currentDate.difference(dob).inDays ~/ 365;
      if (age < 18) {
        dateOfBirthErrorMessage = 'You must be at least 18 years old';
      } else {
        dateOfBirthErrorMessage = null;
      }
    }
    notifyListeners();
  }

  void _validateMobileNumberRealTime() {
    final mobilePattern = RegExp(r'^\+216\d{8}$');
    if (mobileNumberController.text.trim().isEmpty) {
      mobileNumberErrorMessage = 'Mobile number is required';
    } else if (!mobilePattern.hasMatch(mobileNumberController.text.trim())) {
      mobileNumberErrorMessage = 'Please enter a valid Tunisian mobile number (e.g., +21612345678)';
    } else {
      mobileNumberErrorMessage = null;
    }
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> signUp(BuildContext context) async {
    errorMessage = null;
    notifyListeners();

    // Check if there are any real-time errors
    if (nameErrorMessage != null ||
        emailErrorMessage != null ||
        passwordErrorMessage != null ||
        confirmPasswordErrorMessage != null ||
        dateOfBirthErrorMessage != null ||
        mobileNumberErrorMessage != null) {
      errorMessage = 'Please fix the errors in the form';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Update UserModel with form data
      userModel.name = nameController.text.trim();
      userModel.email = emailController.text.trim();
      userModel.password = passwordController.text.trim();
      userModel.dateOfBirth = dateOfBirthController.text.trim();
      userModel.mobileNumber = mobileNumberController.text.trim();

      // Sign up using AuthService
      UserCredential userCredential = await _authService.signUp(
        name: userModel.name,
        email: userModel.email,
        password: userModel.password,
        dateOfBirth: userModel.dateOfBirth,
        mobileNumber: userModel.mobileNumber,
      );

      // Set the user's UID
      userModel.id = userCredential.user?.uid;

      // Store user data in Firestore only if sign-up succeeds
      if (userModel.id != null) {
        await _firestore
            .collection('users')
            .doc(userModel.id)
            .set({
              ...userModel.toMap(),
              'hasSetBalance': false, // Explicitly set to false
            });
      }

      // Sign out the user after successful signup
      await _auth.signOut();
      await _authService.signOut();

      if (context.mounted) {
        context.go('/login');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use. Please log in instead.';
        if (context.mounted) {
          context.go('/login'); // Redirect to login page
        }
      } else {
        errorMessage = _getErrorMessage(e.code);
      }
      notifyListeners();
    } catch (e) {
      errorMessage = 'Sign-up failed: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(BuildContext context) async {
    errorMessage = null;
    notifyListeners();

    // Validate email and password for login
    _validateEmailRealTime();
    _validatePasswordRealTime();

    if (emailErrorMessage != null || passwordErrorMessage != null) {
      errorMessage = 'Please fix the errors in the form';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      // Update UserModel with form data
      userModel.email = emailController.text.trim();
      userModel.password = passwordController.text.trim();

      // Sign in using AuthService
      UserCredential userCredential = await _authService.signIn(
        email: userModel.email,
        password: userModel.password,
      );

      if (userCredential.user != null && context.mounted) {
        context.go('/');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e.code);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Sign-in failed: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      UserCredential? userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        errorMessage = 'Google Sign-In was canceled';
        notifyListeners();
        return;
      }

      // Fetch or create user data in Firestore
      User? user = userCredential.user;
      if (user != null) {
        userModel.id = user.uid;
        userModel.email = user.email ?? '';
        userModel.name = user.displayName ?? '';
        // Default values for other fields if signing in with Google
        userModel.dateOfBirth = userModel.dateOfBirth.isEmpty ? '01/01/2000' : userModel.dateOfBirth;
        userModel.mobileNumber = userModel.mobileNumber.isEmpty ? '+21612345678' : userModel.mobileNumber;

        await _firestore
            .collection('users')
            .doc(userModel.id)
            .set(userModel.toMap(), SetOptions(merge: true));
      }

      if (context.mounted) {
        context.go('/');
      }
    } catch (e) {
      errorMessage = 'Google Sign-In failed: $e';
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _authService.signOut();
    userModel = UserModel();
    clearForm();
    notifyListeners();
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    dateOfBirthController.clear();
    mobileNumberController.clear();
    nameErrorMessage = null;
    emailErrorMessage = null;
    passwordErrorMessage = null;
    confirmPasswordErrorMessage = null;
    dateOfBirthErrorMessage = null;
    mobileNumberErrorMessage = null;
    errorMessage = null;
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
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