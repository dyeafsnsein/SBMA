import 'package:flutter/material.dart';

class FooterComponent_SignUpSectionComponent extends StatelessWidget {
  const FooterComponent_SignUpSectionComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () {
              // Handle forgot password
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF202422),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: 207,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                // Handle sign up
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.5),
                ),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xFF202422),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Use fingerprint to access',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFFFCFCFC),
            ),
          ),
          SizedBox(height: 15),
          Text(
            'or sign up with',
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontWeight: FontWeight.w300,
              fontSize: 13,
              color: Color(0xFF202422),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  // Handle Facebook login
                },
                child: Image.network(
                  'https://dashboard.codeparrot.ai/api/image/Z7uZpFCHtJJZ6wGS/facebook.png',
                  width: 32.71,
                  height: 32.65,
                ),
              ),
              SizedBox(width: 16),
              InkWell(
                onTap: () {
                  // Handle Google login
                },
                child: Image.network(
                  'https://dashboard.codeparrot.ai/api/image/Z7uZpFCHtJJZ6wGS/google.png',
                  width: 32.71,
                  height: 32.71,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          TextButton(
            onPressed: () {
              // Handle sign up navigation
            },
            child: Text(
              'Don\'t have an account? Sign Up',
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w300,
                fontSize: 13,
                color: Color(0xFF202422),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

