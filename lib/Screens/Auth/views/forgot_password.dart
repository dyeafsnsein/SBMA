import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/auth_controller.dart';
import 'Login.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    // Get the controller when the widget initializes
    final authController = Provider.of<AuthController>(context, listen: false);
    // Clear any previous email to start fresh
    authController.emailController.clear();
    // Add listener for real-time validation
    authController.emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    // Remove listener when widget disposes
    final authController = Provider.of<AuthController>(context, listen: false);
    authController.emailController.removeListener(_validateEmail);
    super.dispose();
  }

  void _validateEmail() {
    final authController = Provider.of<AuthController>(context, listen: false);
    // We'll use the controller's validation - just need to update our local state
    setState(() {
      _isEmailValid = authController.emailController.text.isNotEmpty && 
                     authController.emailErrorMessage == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 100, bottom: 20),
                        alignment: Alignment.center,
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(35.0),
                            child: Consumer<AuthController>(
                              builder: (context, authController, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 50),
                                    const Text(
                                      'Reset Password?',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF202422),
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      'We will send you a link to reset your password.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF202422)
                                            .withAlpha((0.7 * 255).toInt()),
                                        fontFamily: 'League Spartan',
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                    TextField(
                                      controller: authController.emailController,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Poppins',
                                      ),
                                      decoration: InputDecoration(
                                        labelText: 'Enter Email Address',
                                        hintText: 'example@example.com',
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
                                          color: Colors.black
                                              .withAlpha((0.45 * 255).toInt()),
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        // Use the controller's error message
                                        errorText: authController.emailController.text.isNotEmpty && 
                                                  authController.emailErrorMessage != null
                                            ? authController.emailErrorMessage
                                            : null,
                                        // Show check icon when email is valid
                                        suffixIcon: authController.emailController.text.isNotEmpty
                                            ? Icon(
                                                authController.emailErrorMessage == null
                                                    ? Icons.check_circle
                                                    : Icons.error,
                                                color: authController.emailErrorMessage == null
                                                    ? Colors.green
                                                    : Colors.red,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(height: 45),
                                    Center(
                                      child: SizedBox(
                                        width: 169,
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: authController.isLoading || !_isEmailValid
                                              ? null
                                              : () => authController.sendPasswordResetEmail(context),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isEmailValid
                                                ? const Color(0xFF202422)
                                                : Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Text(
                                            authController.isLoading ? 'Sending...' : 'Next Step',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: SizedBox(
                                        width: 169,
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginPage()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[300],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Center(
                                      child: Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}