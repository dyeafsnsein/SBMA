import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
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
                            // Header Section
                            _buildHeader(),
                            // Form Section
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
                                      // Email Field
                                      _buildEmailField(controller),
                                      const SizedBox(height: 20),
                                      // Password Field
                                      _buildPasswordField(controller),
                                      const SizedBox(height: 30),
                                      // Error Message
                                      if (controller.errorMessage != null)
                                        Text(
                                          controller.errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                      // Login Button
                                      _buildLoginButton(controller, context),
                                      const SizedBox(height: 10),
                                      // Forgot Password Link
                                      _buildForgotPasswordLink(context),
                                      const SizedBox(height: 10),
                                      // Sign Up Button
                                      _buildSignUpButton(context),
                                      const SizedBox(height: 20),
                                      // Fingerprint Access Text
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
                                      // Social Login Section (with Google Login)
                                      _buildSocialLoginSection(controller, context),
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

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildEmailField(LoginController controller) {
    return TextField(
      controller: controller.emailController,
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
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(0, 0, 0, 0.45),
        ),
      ),
    );
  }

  Widget _buildPasswordField(LoginController controller) {
    return TextField(
      controller: controller.passwordController,
      obscureText: !controller.isPasswordVisible,
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
            color: const Color.fromRGBO(0, 0, 0, 0.45),
          ),
          onPressed: () => controller.togglePasswordVisibility(),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginController controller, BuildContext context) {
    return SizedBox(
      width: 210,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () => controller.signIn(context),
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
    );
  }

  Widget _buildForgotPasswordLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go('/forgot-password');
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
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: 210,
      child: ElevatedButton(
        onPressed: () {
          context.go('/signup');
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
    );
  }

  Widget _buildSocialLoginSection(LoginController controller, BuildContext context) {
    return Column(
      children: [
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
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Image.asset(
                'lib/assets/Google.png',
                width: 32.71,
                height: 32.71,
              ),
              onPressed: () => controller.signInWithGoogle(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            context.go('/signup');
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
    );
  }
}