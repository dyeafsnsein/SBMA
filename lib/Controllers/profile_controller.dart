import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  String? errorMessage;
  bool isLoading = false;
  bool _isCurrentlyEditing = false;
  bool _isGoogleUser = false;
  
  // Form validation error messages
  String? usernameErrorMessage;
  String? emailErrorMessage;
  String? passwordErrorMessage;
  String? confirmPasswordErrorMessage;

  bool get isCurrentlyEditing => _isCurrentlyEditing;
  bool get isGoogleUser => _isGoogleUser;

  EditProfileController() {
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();
    
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Check if user signed in with Google
        _isGoogleUser = currentUser.providerData
            .any((userInfo) => userInfo.providerId == 'google.com');
        
        // Load user data from Firestore
        final userData = await _authService.getUserData(currentUser.uid);
        
        if (userData != null) {
          usernameController.text = userData['name'] ?? '';
          emailController.text = currentUser.email ?? '';
        }

        debugPrint('User authentication providers: ${currentUser.providerData.map((p) => p.providerId).toList()}');
        debugPrint('Is Google user: $_isGoogleUser');
      }
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load user data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void startEditing() {
    _isCurrentlyEditing = true;
    notifyListeners();
  }

  void cancelEditing() {
    _isCurrentlyEditing = false;
    // Reset the form
    loadUserData();
    passwordController.clear();
    confirmPasswordController.clear();
    clearErrors();
    notifyListeners();
  }

  void clearErrors() {
    errorMessage = null;
    usernameErrorMessage = null;
    emailErrorMessage = null;
    passwordErrorMessage = null;
    confirmPasswordErrorMessage = null;
    notifyListeners();
  }

  bool validateInputs() {
    bool isValid = true;
    clearErrors();

    // Validate username
    if (usernameController.text.trim().isEmpty) {
      usernameErrorMessage = 'Username cannot be empty';
      isValid = false;
    }

    // Only validate email and password for non-Google users
    if (!_isGoogleUser) {
      // Validate email
      if (emailController.text.trim().isEmpty) {
        emailErrorMessage = 'Email cannot be empty';
        isValid = false;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
        emailErrorMessage = 'Please enter a valid email address';
        isValid = false;
      }

      // Validate passwords only if provided
      if (passwordController.text.isNotEmpty) {
        // Check password complexity
        if (passwordController.text.length < 6) {
          passwordErrorMessage = 'Password must be at least 6 characters';
          isValid = false;
        }
        
        // Confirm passwords match
        if (passwordController.text != confirmPasswordController.text) {
          confirmPasswordErrorMessage = 'Passwords do not match';
          isValid = false;
        }
      }
    }
    
    notifyListeners();
    return isValid;
  }

  Future<bool> updateProfile(BuildContext context) async {
    if (!validateInputs()) {
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently signed in');
      }

      // Prepare data to update
      Map<String, dynamic> userData = {
        'name': usernameController.text.trim(),
      };

      // Update profile in Firestore
      await _authService.updateUserData(currentUser.uid, userData);

      // Only update email and password for non-Google users
      if (!_isGoogleUser) {
        // Update email if changed
        if (currentUser.email != emailController.text.trim()) {
          await currentUser.updateEmail(emailController.text.trim());
        }

        // Update password if provided
        if (passwordController.text.isNotEmpty) {
          await currentUser.updatePassword(passwordController.text);
        }
      }

      // Reset the editing state
      _isCurrentlyEditing = false;
      errorMessage = null;
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
      
      return true;
    } catch (e) {
      errorMessage = 'Failed to update profile: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}