import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/signup_controller.dart';
import '../../../Models/signup_model.dart';
import 'components/FormField.dart' as custom;
import 'components/PasswordField.dart';

@RoutePage()
class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<SignupPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignupController(SignupModel()),
      child: Consumer<SignupController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF202422),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 100, bottom: 20), // Adjusted padding
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              custom.FormField(
                                label: 'Full Name',
                                hintText: 'John Doe',
                                controller: TextEditingController(text: controller.fullName),
                              ),
                              const SizedBox(height: 10),
                              custom.FormField(
                                label: 'Email',
                                hintText: 'example@example.com',
                                controller: TextEditingController(text: controller.email),
                              ),
                              const SizedBox(height: 10),
                              custom.FormField(
                                label: 'Mobile Number',
                                hintText: '+ 123 456 789',
                                controller: TextEditingController(text: controller.mobileNumber),
                              ),
                              const SizedBox(height: 10),
                              custom.FormField(
                                label: 'Date of Birth',
                                hintText: 'DD / MM / YYYY',
                                controller: TextEditingController(text: controller.dateOfBirth),
                              ),
                              const SizedBox(height: 10),
                              PasswordField(
                                label: 'Password',
                                isVisible: _isPasswordVisible,
                                onVisibilityChanged: (value) {
                                  setState(() {
                                    _isPasswordVisible = value;
                                  });
                                },
                                controller: TextEditingController(text: controller.password),
                              ),
                              const SizedBox(height: 10),
                              PasswordField(
                                label: 'Confirm Password',
                                isVisible: _isConfirmPasswordVisible,
                                onVisibilityChanged: (value) {
                                  setState(() {
                                    _isConfirmPasswordVisible = value;
                                  });
                                },
                                controller: TextEditingController(text: controller.confirmPassword),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 210,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add your sign up logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF202422),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  // Navigate to Log In
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Already have an account? Log In',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
