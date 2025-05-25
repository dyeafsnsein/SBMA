import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Services/auth_service.dart';
import '../commons/form_validators.dart';

class EditProfileController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
    // No more local validation listeners; use FormValidators in the UI or in submit methods.
  }

  // When loading user data, use the more efficient combined method if the user is already authenticated
  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      if (_auth.currentUser != null) {
        final userData = await _authService.getUserData(_auth.currentUser!.uid);
        if (userData != null) {
          usernameController.text = userData['name'] ?? '';
          emailController.text = _auth.currentUser!.email ?? '';
        } else {
          usernameController.text = _auth.currentUser!.displayName ?? '';
          emailController.text = _auth.currentUser!.email ?? '';
        }
      }

      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Check if user signed in with Google
        _isGoogleUser = currentUser.providerData
            .any((userInfo) => userInfo.providerId == 'google.com');

        debugPrint(
            'User authentication providers: ${currentUser.providerData.map((p) => p.providerId).toList()}');
        debugPrint('Is Google user: $_isGoogleUser');
      }
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Failed to load user data: $e';
      debugPrint('Error in loadUserData: $e');
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

  Future<bool> reauthenticateUser(String email, String password) async {
    try {
      final user = _auth.currentUser!;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      errorMessage = _handleAuthError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(BuildContext context) async {
    // Use FormValidators for validation
    usernameErrorMessage = FormValidators.validateName(usernameController.text);
    emailErrorMessage = !_isGoogleUser ? FormValidators.validateEmail(emailController.text) : null;
    passwordErrorMessage = (!_isGoogleUser && passwordController.text.isNotEmpty)
      ? FormValidators.validatePassword(passwordController.text)
      : null;
    confirmPasswordErrorMessage = (!_isGoogleUser && passwordController.text.isNotEmpty)
      ? FormValidators.validateConfirmPassword(passwordController.text, confirmPasswordController.text)
      : null;

    if (usernameErrorMessage != null ||
        (!_isGoogleUser && (
          emailErrorMessage != null ||
          (passwordController.text.isNotEmpty && (passwordErrorMessage != null || confirmPasswordErrorMessage != null))
        ))) {
      notifyListeners();
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
      final Map<String, dynamic> userData = {
        'name': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'dateOfBirth': '',
        'mobileNumber': '',
      };

      // Re-authenticate if email is changing (non-Google users)
      if (!_isGoogleUser && currentUser.email != emailController.text.trim()) {
        if (passwordController.text.isEmpty) {
          errorMessage = 'Password is required to change email';
          isLoading = false;
          notifyListeners();
          return false;
        }
        final reauthenticated = await reauthenticateUser(
          currentUser.email!,
          passwordController.text,
        );
        if (!reauthenticated) {
          isLoading = false;
          notifyListeners();
          return false;
        }

        // Update email with verification
        await currentUser.verifyBeforeUpdateEmail(emailController.text.trim());
      }

      // Update profile in Firestore
      await _authService.updateUserData(currentUser.uid, userData);

      // Only update password if provided
      if (!_isGoogleUser && passwordController.text.isNotEmpty) {
        await currentUser.updatePassword(passwordController.text);
      }

      // Update displayName in Firebase Authentication
      await currentUser.updateDisplayName(usernameController.text.trim());

      // Reset the editing state
      _isCurrentlyEditing = false;
      errorMessage = null;

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isGoogleUser
                  ? 'Username updated successfully'
                  : 'Profile updated. Please verify your new email.',
            ),
          ),
        );
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _handleAuthError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'The email is already in use by another account.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'requires-recent-login':
          return 'Please sign out and sign in again to perform this action.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'An error occurred: e.message';
      }
    }
    return 'An unexpected error occurred: $e';
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
