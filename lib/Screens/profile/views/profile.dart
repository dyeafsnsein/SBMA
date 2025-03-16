import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          // Minimal Header
          Container(
            padding: EdgeInsets.only(
              top: topPadding,
              left: screenWidth * 0.06,
              right: screenWidth * 0.06,
            ),
            height: screenHeight * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),
                Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/notification'),
                  child: Container(
                    padding: EdgeInsets.all(screenWidth * 0.02),
                    decoration: BoxDecoration(
                      color: const Color(0xFF050505),
                      borderRadius: BorderRadius.circular(screenWidth * 0.90),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: screenWidth * 0.045,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Stack(
              children: [
                // White background container that fills the remaining space
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
                
                // Scrollable content
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
                          Text(
                            'John Smith',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.05, // Slightly larger
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF202422),
                            ),
                          ),
                          Text(
                            'ID: 25030024',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04, // Slightly larger
                              color: const Color(0xFF202422),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          
                          // Profile options list
                          ListView(
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
                                onTap: () {},
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
                          ),
                          // Add extra space at the bottom to ensure scrolling works properly
                          SizedBox(height: screenHeight * 0.1),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Profile Image
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircleAvatar(
                      radius: screenWidth * 0.13, // Slightly larger
                      backgroundImage: const AssetImage('lib/assets/profile_image.png'),
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
}