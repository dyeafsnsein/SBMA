import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                'SBMA',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.bar_chart_outlined,
                size: 80,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Hey There.',
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
                },                onTapUp: (_) {
                  setState(() {
                    _isLoginPressed = false;
                  });
                  // Navigate to the LoginPage using GoRouter
                  context.go('/login');
                },
                onTapCancel: () {
                  setState(() {
                    _isLoginPressed = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
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
                },                onTapUp: (_) {
                  setState(() {
                    _isSignUpPressed = false;
                  });
                  // Navigate to the SignupPage using GoRouter
                  context.go('/signup');
                },
                onTapCancel: () {
                  setState(() {
                    _isSignUpPressed = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 65, vertical: 15),
                  decoration: BoxDecoration(
                    color:
                        _isSignUpPressed ? Colors.grey[100] : Colors.grey[300],
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
            
            ],
          ),
        ),
      ),
    );
  }
}
