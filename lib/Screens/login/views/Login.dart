import 'package:flutter/material.dart';
import '../../signup/views/Signup.dart';
import 'forgot_password.dart';
import '../../security/views/SecurityPin.dart'; // Import the SecurityPinWidget
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/login_controller.dart';
import '../../../Models/login_model.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(LoginModel()),
      child: Consumer<LoginController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF202422),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 100, bottom: 20),
                              child: const Text(
                                'Welcome',
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
                                      const SizedBox(height: 90),
                                      TextField(
                                        onChanged: controller.setEmail,
                                        decoration: InputDecoration(
                                          labelText: 'Username or Email',
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
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black.withOpacity(0.45),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      TextField(
                                        obscureText: !controller.isPasswordVisible,
                                        onChanged: controller.setPassword,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
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
                                              controller.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                              color: Colors.black.withOpacity(0.45),
                                            ),
                                            onPressed: controller.togglePasswordVisibility,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      SizedBox(
                                        width: 210,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SecurityPinWidget()),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF202422),
                                            padding: const EdgeInsets.symmetric(vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: const Text(
                                            'Log In',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                                          );
                                        },
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: 210,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) => const SignupPage()),
                                            );
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
                                              color: Colors.black,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'Use Fingerprint to Access',
                                        style: TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'or sign up with',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'League Spartan',
                                          fontWeight: FontWeight.w300,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Image.asset(
                                              'lib/assets/Facebook.png',
                                              width: 32.71,
                                              height: 32.65,
                                            ),
                                            onPressed: () {
                                              // Facebook login logic
                                            },
                                          ),
                                          const SizedBox(width: 16),
                                          IconButton(
                                            icon: Image.asset(
                                              'lib/assets/Google.png',
                                              width: 32.71,
                                              height: 32.71,
                                            ),
                                            onPressed: () {
                                              // Google login logic
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => const SignupPage()),
                                          );
                                        },
                                        child: const Text(
                                          'Don’t have an account? Sign Up',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'League Spartan',
                                            fontWeight: FontWeight.w300,
                                            fontSize: 13,
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
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
