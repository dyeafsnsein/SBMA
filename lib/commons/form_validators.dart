// Centralized form validators for all forms (signup, login, edit profile, etc.)
// Usage: Import and use FormValidators static methods in any UI/controller

class FormValidators {
  static String? validateEmail(String email) {
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (email.trim().isEmpty) {
      return 'Email is required';
    } else if (!emailPattern.hasMatch(email.trim())) {
      return 'Please enter a valid email (e.g., test@test.test)';
    }
    return null;
  }

  static String? validatePassword(String password) {
    final passwordPattern = RegExp(r'^(?=.*[0-9])(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#\$%^&*]).{6,}$');
    if (password.trim().isEmpty) {
      return 'Password is required';
    } else if (!passwordPattern.hasMatch(password.trim())) {
      return 'Password must contain at least one number, one uppercase letter, one lowercase letter, and one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.trim().isEmpty) {
      return 'Confirm password is required';
    } else if (password.trim() != confirmPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String name) {
    final namePattern = RegExp(r'^[a-zA-Z\s]+$');
    if (name.trim().isEmpty) {
      return 'Full name is required';
    } else if (!namePattern.hasMatch(name.trim())) {
      return 'Full name should contain only alphabets and spaces';
    }
    return null;
  }

  static String? validateDateOfBirth(String dob, {DateTime? currentDate}) {
    final datePattern = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (dob.trim().isEmpty) {
      return 'Date of birth is required';
    } else if (!datePattern.hasMatch(dob.trim())) {
      return 'Please enter a valid date of birth (DD/MM/YYYY)';
    } else {
      try {
        final dobParts = dob.trim().split('/');
        final date = DateTime(
          int.parse(dobParts[2]), // Year
          int.parse(dobParts[1]), // Month
          int.parse(dobParts[0]), // Day
        );
        final now = currentDate ?? DateTime.now();
        final age = now.difference(date).inDays ~/ 365;
        if (age < 18) {
          return 'You must be at least 18 years old';
        }
      } catch (_) {
        return 'Please enter a valid date of birth (DD/MM/YYYY)';
      }
    }
    return null;
  }

  static String? validateMobileNumber(String mobile) {
    final mobilePattern = RegExp(r'^\+216\d{8} ?$');
    if (mobile.trim().isEmpty) {
      return 'Mobile number is required';
    } else if (!mobilePattern.hasMatch(mobile.trim())) {
      return 'Please enter a valid Tunisian mobile number (e.g., +21612345678)';
    }
    return null;
  }
}

// Centralized error handling utility
class ErrorHandler {
  static String firebaseAuthError(dynamic error) {
    // Import is not needed here, but in usage files: import 'package:firebase_auth/firebase_auth.dart';
    if (error is String) return error;
    if (error is Exception && error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    String? code;
    try {
      code = error.code;
    } catch (_) {}
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already in use. Please log in instead.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to perform this action.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        try {
          if (error.message != null) return error.message;
        } catch (_) {}
        return 'An unknown error occurred.';
    }
  }

  static String generalError(dynamic error) {
    if (error is String) return error;
    if (error is Exception && error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
