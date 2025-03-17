import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/custom_header.dart';

class AddFingerprint extends StatelessWidget {
  const AddFingerprint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Add Fingerprint'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202422),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/Fingerprint.png',
                        width: screenWidth * 0.15,
                        height: screenWidth * 0.15,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Use Fingerprint To Access',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: screenWidth * 0.05,
                      color: const Color(0xFF202422),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: screenWidth * 0.035,
                      color: const Color(0xFF202422),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/success2');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF202422),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: Text(
                      'Use Touch Id',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}