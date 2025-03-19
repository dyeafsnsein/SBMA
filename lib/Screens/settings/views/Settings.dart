import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/custom_header.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Settings'),
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
                  SizedBox(height: screenHeight * 0.03),
                  _buildSettingsOption(
                    context: context,
                    iconPath: 'lib/assets/Notification.png',
                    title: 'Notification Settings',
                    onTap: () {
                      // Handle navigation to Notification Settings
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSettingsOption(
                    context: context,
                    iconPath: 'lib/assets/Key.png',
                    title: 'Password Settings',
                    onTap: () {
                      // Handle navigation to Password Settings
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildSettingsOption(
                    context: context,
                    iconPath: 'lib/assets/Profile.png',
                    title: 'Delete Account',
                    onTap: () {
                      // Handle navigation to Delete Account
                    },
                    titleColor: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    Color titleColor = const Color(0xFF202422),
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
                color: titleColor,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: titleColor,
              size: screenWidth * 0.045,
            ),
          ],
        ),
      ),
    );
  }
}