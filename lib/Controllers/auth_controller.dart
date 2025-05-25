import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/user_model.dart';
import '../Services/auth_service.dart';
import 'package:go_router/go_router.dart';
import '../commons/form_validators.dart';
import '../commons/error_handler.dart' as app_errors;

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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  AuthController() {
    // No more real-time validation listeners here; use FormValidators in the UI or in submit methods.
    loadCurrentUser();

    // Listen for auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadCurrentUser();
      } else {
        userModel = UserModel();
      }
    });
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

    // Use FormValidators for validation
    nameErrorMessage = FormValidators.validateName(nameController.text);
    emailErrorMessage = FormValidators.validateEmail(emailController.text);
    passwordErrorMessage = FormValidators.validatePassword(passwordController.text);
    confirmPasswordErrorMessage = FormValidators.validateConfirmPassword(passwordController.text, confirmPasswordController.text);
    dateOfBirthErrorMessage = FormValidators.validateDateOfBirth(dateOfBirthController.text);
    mobileNumberErrorMessage = FormValidators.validateMobileNumber(mobileNumberController.text);

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

      // Sign up using AuthService - this now handles both account creation and data storage
      UserCredential userCredential = await _authService.signUp(
        name: userModel.name,
        email: userModel.email,
        password: userModel.password,
        dateOfBirth: userModel.dateOfBirth,
        mobileNumber: userModel.mobileNumber,
      );      // Set the user's UID in the model
      userModel.id = userCredential.user?.uid;
      
      // Add debug print
      debugPrint("Successfully signed up user with ID: ${userModel.id}");
      debugPrint("User is logged in: ${FirebaseAuth.instance.currentUser != null}");
      
      // Keep the user logged in and redirect to set-balance page
      if (context.mounted) {
        // Use GoRouter directly for navigation to ensure consistent behavior
        debugPrint("Navigating to /set-balance");
        context.go('/set-balance');
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = app_errors.ErrorHandler.firebaseAuthError(e);
      if (e.code == 'email-already-in-use' && context.mounted) {
        context.go('/login');
      }
      notifyListeners();
    } catch (e) {
      errorMessage = app_errors.ErrorHandler.generalError(e);
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(BuildContext context) async {
    errorMessage = null;
    notifyListeners();

    // Use FormValidators for validation
    emailErrorMessage = FormValidators.validateEmail(emailController.text);
    passwordErrorMessage = FormValidators.validatePassword(passwordController.text);

    if (emailErrorMessage != null || passwordErrorMessage != null) {
      errorMessage = 'Please fix the errors in the form';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> result = await _authService.signInAndGetUserData(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      UserCredential userCredential = result['userCredential'];
      Map<String, dynamic>? userData = result['userData'];
      bool isFirstTimeUser = result['isFirstTimeUser'];

      // Update user model
      userModel.id = userCredential.user!.uid;
      if (userData != null) {
        userModel = UserModel.fromMap(userData, id: userModel.id);
      }

      // Navigate based on isFirstTimeUser flag
      if (context.mounted) {
        if (isFirstTimeUser) {
          context.go('/set-balance');
        } else {
          context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = app_errors.ErrorHandler.firebaseAuthError(e);
      notifyListeners();
    } catch (e) {
      errorMessage = app_errors.ErrorHandler.generalError(e);
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
      Map<String, dynamic>? result = await _authService.signInWithGoogleAndGetUserData();
      if (result == null) {
        errorMessage = 'Google Sign-In was canceled';
        notifyListeners();
        return;
      }
      
      UserCredential userCredential = result['userCredential'];
      Map<String, dynamic>? userData = result['userData'];
      bool isFirstTimeUser = result['isFirstTimeUser'];
      
      // Update user model
      userModel.id = userCredential.user!.uid;
      if (userData != null) {
        userModel = UserModel.fromMap(userData, id: userModel.id);
      }
      
      // Navigate based on isFirstTimeUser flag
      if (context.mounted) {
        if (isFirstTimeUser) {
          context.go('/set-balance');
        } else {
          context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = app_errors.ErrorHandler.firebaseAuthError(e);
      notifyListeners();
    } catch (e) {
      errorMessage = app_errors.ErrorHandler.generalError(e);
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
  // Add this method to AuthController
  Future<bool> setInitialBalance(double balance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();
    try {
      // Update balance in Firestore
      await _authService.updateBalance(user.uid, balance);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = app_errors.ErrorHandler.generalError(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> sendPasswordResetEmail(BuildContext context) async {
    errorMessage = null;
    notifyListeners();
    // Use FormValidators for validation
    emailErrorMessage = FormValidators.validateEmail(emailController.text);
    if (emailErrorMessage != null) {
      errorMessage = 'Please enter a valid email address';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset link sent!')),
        );
      }
      
      // Optional: Navigate back to login page

    } on FirebaseAuthException catch (e) {
      errorMessage = app_errors.ErrorHandler.firebaseAuthError(e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Failed to send reset link')),
        );
      }
    } catch (e) {
      errorMessage = app_errors.ErrorHandler.generalError(e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage ?? 'Failed to send reset link')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
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

  // Method to load current user data
  Future<void> loadCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userData =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userData.exists) {
          userModel = UserModel.fromMap(
            userData.data() as Map<String, dynamic>,
            id: currentUser.uid,
          );
          debugPrint('User data loaded: ${userModel.name}');
        } else {
          // If user exists in auth but not in Firestore, create basic record
          userModel = UserModel(
            id: currentUser.uid,
            email: currentUser.email ?? '',
            name: currentUser.displayName ?? '',
          );
          await _firestore.collection('users').doc(currentUser.uid).set(
                userModel.toMap(),
                SetOptions(merge: true),
              );
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
  }
}
