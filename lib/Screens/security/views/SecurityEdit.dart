import 'package:flutter/material.dart';
import '../../../shared_components/custom_header.dart';
import 'package:go_router/go_router.dart';
class SecurityEdit extends StatelessWidget {
  const SecurityEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Security'),
          Expanded(
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1FFF3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
                
                // Security content
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        Text(
                          'Security Settings',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202422),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        _buildSecurityOption(
                          context: context,
                          title: 'Change Pin',
                          onTap: () {context.push('/profile/security-edit/change-pin');},
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildSecurityOption(
                          context: context,
                          title: 'Fingerprint',
                          onTap: () {context.push('/profile/security-edit/fingerprint');},
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        _buildSecurityOption(
                          context: context,
                          title: 'Terms And Conditions',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.045,
                color: const Color(0xFF202422),
              ),
            ),
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