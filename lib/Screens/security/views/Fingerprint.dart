import 'package:flutter/material.dart';
import '../../../shared_components/custom_header.dart';

class Fingerprint extends StatelessWidget {
  const Fingerprint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Fingerprint'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  _buildFingerprintOption(
                    context: context,
                    iconPath: 'lib/assets/Fingerprint.png',
                    title: 'John Fingerprint',
                    onTap: () {
                      // Handle fingerprint option tap
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFingerprintOption(
                    context: context,
                    iconPath: 'lib/assets/More.png',
                    title: 'Add A Fingerprint',
                    onTap: () {
                      // Handle add fingerprint option tap
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFingerprintOption({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF202422),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.045,
                color: const Color(0xFF202422),
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF202422),
              size: screenWidth * 0.045,
            ),
          ],
        ),
      ),
    );
  }
}