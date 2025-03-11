import 'package:flutter/material.dart';
import '../../security/views/SecurityPin.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

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
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
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
                            child: Column(
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
                                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF202422).withOpacity(0.7),
                                    fontFamily: 'League Spartan',
                                  ),
                                ),
                                const SizedBox(height: 50),
                                TextField(
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
                                      color: Colors.black.withOpacity(0.45),
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                ),
                                const SizedBox(height: 45),
                                Center(
                                  child: SizedBox(
                                    width: 169,
                                    height: 32,
                                    child: ElevatedButton(
                                        onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SecurityPinWidget()),
                                      );
                                    },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF202422),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text(
                                        'Next Step',
                                        style: TextStyle(
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
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text(
                                        'Sign Up',
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
                                Center(
                                  child: Column(
                                    children: [
                                      const Text(
                                        'or sign up with',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF202422),
                                          fontFamily: 'League Spartan',
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
                                      const Text(
                                        'Don\'t have an account? Sign Up',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w300,
                                          color: Color(0xFF202422),
                                          fontFamily: 'League Spartan',
                                        ),
                                      ),
                                    ],
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
  }
}
