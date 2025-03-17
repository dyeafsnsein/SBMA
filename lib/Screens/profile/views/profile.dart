import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import '../../../shared_components/custom_header.dart';
import '../../../shared_components/profile_image.dart';
import '../../../shared_components/profile_info.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Profile'),
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
                
                // Profile content
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1FFF3),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        screenWidth * 0.06,
                        screenHeight * 0.08,
                        screenWidth * 0.06,
                        screenHeight * 0.02,
                      ),
                      child: Column(
                        children: [
                          const ProfileInfo(
                            name: 'John Smith',
                            id: '25030024',
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          _buildProfileOptions(context),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Profile Image
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ProfileImage(
                      imagePath: 'lib/assets/profile_image.png',
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

  Widget _buildProfileOption({
    required String iconPath,
    required String title,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03), // Slightly larger spacing
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.12, // Slightly larger
              height: screenWidth * 0.12, // Slightly larger
              decoration: BoxDecoration(
                color: const Color(0xFF202422),
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: screenWidth * 0.06, // Slightly larger
                  height: screenWidth * 0.06, // Slightly larger
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.045, // Slightly larger
                color: const Color(0xFF202422),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildProfileOption(
          iconPath: 'lib/assets/Profile.png',
          title: 'Edit Profile',
          onTap: () {context.push('/profile/edit-profile');},
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Security.png',
          title: 'Security',
          onTap: () {context.push('/profile/security-edit');},
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Settings.png',
          title: 'Setting',
          onTap: () {},
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Help.png',
          title: 'Help',
          onTap: () {},
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Logout.png',
          title: 'Logout',
          onTap: () {},
          screenWidth: screenWidth,
        ),
      ],
    );
  }
}