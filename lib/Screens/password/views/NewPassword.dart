import 'package:flutter/material.dart';
import '../../login/views/PasswordChanged.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _NewPasswordWidgetState createState() => _NewPasswordWidgetState();
}

class _NewPasswordWidgetState extends State<ForgotPasswordPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        child: Column(
          children: [
            // Dark grey top section
            Expanded(
              flex: 16,
              child: Container(
                color: const Color(0xFF202422),
                child: const Center(
                  child: Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            // White rectangle with rounded top corners
            Expanded(
              flex: 65,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // New Password
                      _buildPasswordField(
                        label: 'New Password',
                        isVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Confirm New Password
                      _buildPasswordField(
                        label: 'Confirm New Password',
                        isVisible: _isConfirmPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      // Change Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PasswordChangedWidget(),
                              ),
                            );
                          },
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF202422),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Change Password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF202422),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          obscureText: !isVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF202422),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
