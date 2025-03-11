import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

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
                        _buildFormField(
                          label: 'Full Name',
                          hintText: 'John Doe',
                        ),
                        const SizedBox(height: 10),
                        _buildFormField(
                          label: 'Email',
                          hintText: 'example@example.com',
                        ),
                        const SizedBox(height: 10),
                        _buildFormField(
                          label: 'Mobile Number',
                          hintText: '+ 123 456 789',
                        ),
                        const SizedBox(height: 10),
                        _buildFormField(
                          label: 'Date of Birth',
                          hintText: 'DD / MM / YYYY',
                        ),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          label: 'Password',
                          isVisible: _isPasswordVisible,
                          onVisibilityChanged: (value) {
                            setState(() {
                              _isPasswordVisible = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildPasswordField(
                          label: 'Confirm Password',
                          isVisible: _isConfirmPasswordVisible,
                          onVisibilityChanged: (value) {
                            setState(() {
                              _isConfirmPasswordVisible = value;
                            });
                          },
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
                                color: const Color(0xFF202422),
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
  }

  Widget _buildFormField({
    required String label,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withOpacity(0.45),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          obscureText: !isVisible,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withOpacity(0.45),
              ),
              onPressed: () => onVisibilityChanged(!isVisible),
            ),
          ),
        ),
      ],
    );
  }
}
