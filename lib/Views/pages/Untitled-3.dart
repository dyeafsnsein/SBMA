import 'package:flutter/material.dart';
import 'HeaderComponent.dart';
import 'LoginFormComponent.dart';
import 'FooterComponent_SignUpSectionComponent.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF202422),
      body: Center(
        child: Container(
          width: 430,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              HeaderComponent(),
              SizedBox(height: 20),
              Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: LoginFormComponent(),
              ),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                child: FooterComponent_SignUpSectionComponent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
