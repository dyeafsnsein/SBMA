import 'package:flutter/material.dart';
import 'package:test_app/Screens/login/views/Login.dart';
import 'package:test_app/Screens/signup/views/Signup.dart';


class LaunchPage extends StatefulWidget {
  const LaunchPage({Key? key}) : super(key: key);

  @override
  _LaunchPageState createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  bool _isLoginPressed = false;
  bool _isSignUpPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Flousi',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.bar_chart_outlined,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Log In Button
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isLoginPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isLoginPressed = false;
                  });
                  // Navigate to the LoginPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const LoginPage()),
                  );
                },
                onTapCancel: () {
                  setState(() {
                    _isLoginPressed = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                  decoration: BoxDecoration(
                    color: _isLoginPressed ? Colors.black54 : Colors.black87,
                    borderRadius: BorderRadius.circular(24),
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
              // Sign Up Button
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isSignUpPressed = true;
                  });
                },
                onTapUp: (_) {
                  setState(() {
                    _isSignUpPressed = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const SignupPage()),
                  );
                  // Add your signup functionality here
                },
                onTapCancel: () {
                  setState(() {
                    _isSignUpPressed = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                  decoration: BoxDecoration(
                    color: _isSignUpPressed ? Colors.grey[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
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
              GestureDetector(
                onTap: () {
                  // Add your forgot password functionality here
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}