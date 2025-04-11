import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../services/auth_service.dart';
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
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFF202422),
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
              ),
              child: Center(
                child: Image.asset(
                  iconPath,
                  width: screenWidth * 0.06,
                  height: screenWidth * 0.06,
                  color: Colors.white,
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
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final AuthService authService = AuthService();
    try {
      await authService.signOut();
      // Navigate to login page after successful logout
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      // Show error message if logout fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _logout(context);
    }
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
          onTap: () {
            context.push('/profile/edit-profile');
          },
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Security.png',
          title: 'Security',
          onTap: () {
            context.push('/profile/security-edit');
          },
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Settings.png',
          title: 'Setting',
          onTap: () {
            context.push('/profile/settings');
          },
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Help.png',
          title: 'Help',
          onTap: () {
            context.push('/profile/help-center');
          },
          screenWidth: screenWidth,
        ),
        _buildProfileOption(
          iconPath: 'lib/assets/Logout.png',
          title: 'Logout',
          onTap: () {
            _confirmLogout(context);
          },
          screenWidth: screenWidth,
        ),
      ],
    );
  }
}