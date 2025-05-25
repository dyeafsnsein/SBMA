/// Centralized error handling utility for authentication and general errors.
/// Use this everywhere in the app for consistent error messages.
class ErrorHandler {
  static String firebaseAuthError(dynamic error) {
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
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different credential.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user.';
      case 'invalid-credential':
        return 'The credential is invalid or expired.';
      case 'user-mismatch':
        return 'The credential does not correspond to the given user.';
      case 'provider-already-linked':
        return 'This provider is already linked to the user.';
      case 'no-such-provider':
        return 'No such provider for this user.';
      case 'invalid-action-code':
        return 'The action code is invalid or expired.';
      case 'expired-action-code':
        return 'The action code has expired.';
      case 'invalid-phone-number':
        return 'The phone number is invalid.';
      case 'missing-verification-code':
        return 'Please enter the verification code.';
      case 'missing-verification-id':
        return 'Missing verification ID.';
      case 'missing-email':
        return 'Please enter your email address.';
      case 'missing-password':
        return 'Please enter your password.';
      case 'missing-android-pkg-name':
      case 'missing-continue-uri':
      case 'missing-ios-bundle-id':
        return 'A required parameter is missing. Please contact support.';
      case 'invalid-continue-uri':
        return 'The continue URL is invalid.';
      case 'unauthorized-continue-uri':
        return 'The continue URL is not authorized.';
      case 'user-token-expired':
        return 'Your session has expired. Please sign in again.';
      case 'invalid-custom-token':
        return 'The custom token is invalid.';
      case 'custom-token-mismatch':
        return 'The custom token does not match the expected project.';
      // Add more Firebase Auth errors as needed
      default:
        try {
          if (error.message != null) return error.message;
        } catch (_) {}
        return 'An unknown authentication error occurred.';
    }
  }

  static String firestoreError(dynamic error) {
    if (error is String) return error;
    if (error is Exception && error.toString().contains('PERMISSION_DENIED')) {
      return 'You do not have permission to perform this action.';
    }
    if (error is Exception && error.toString().contains('NOT_FOUND')) {
      return 'The requested data was not found.';
    }
    if (error is Exception && error.toString().contains('UNAVAILABLE')) {
      return 'Firestore service is currently unavailable. Please try again later.';
    }
    return 'A database error occurred. Please try again.';
  }

  static String networkError(dynamic error) {
    if (error is String && error.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    if (error is Exception && error.toString().contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'A network error occurred. Please try again.';
  }

  static String platformError(dynamic error) {
    if (error is String) return error;
    if (error is Exception && error.toString().contains('PlatformException')) {
      return 'A platform error occurred. Please try again.';
    }
    return 'An unexpected platform error occurred.';
  }

  static String generalError(dynamic error) {
    if (error is String) return error;
    if (error is Exception && error.toString().contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    }
    if (error is Exception && error.toString().contains('TimeoutException')) {
      return 'The operation timed out. Please try again.';
    }
    if (error is Exception && error.toString().contains('SocketException')) {
      return 'No internet connection.';
    }
    if (error is Exception && error.toString().contains('PlatformException')) {
      return 'A platform error occurred. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
