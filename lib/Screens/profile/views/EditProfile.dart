import 'package:flutter/material.dart';
import '../../../shared_components/custom_header.dart';
import '../../../shared_components/profile_image.dart';
import '../../../shared_components/profile_info.dart';
import '../../../shared_components/settings_form_field.dart';
import '../../../shared_components/settings_toggle.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isPushNotificationsEnabled = true;
  bool isDarkThemeEnabled = false;

  final TextEditingController usernameController = TextEditingController(text: 'John Smith');
  final TextEditingController phoneController = TextEditingController(text: '+44 555 5555 55');
  final TextEditingController emailController = TextEditingController(text: 'example@example.com');

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Calculate profile image size
    const defaultRadius = 0.13; // From ProfileImage default
    final profileRadius = screenWidth * defaultRadius > 50 ? 50 : screenWidth * defaultRadius; // Reduced cap to 50px
    final profileDiameter = profileRadius * 2; // CircleAvatar uses radius, so diameter is 2x

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        bottom: false, // Allow content to extend under bottom nav
        child: Column(
          children: [
            const CustomHeader(title: 'Edit Profile'),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none, // Allow overflow for profile image
                children: [
                  // White container
                  Container(
                    margin: EdgeInsets.only(top: profileDiameter / 2), // Half of image height
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: profileDiameter / 2 + screenHeight * 0.01), // Reduced space for image overlap
                          const ProfileInfo(
                            name: 'John Smith',
                            id: '25030024',
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          // Settings Content
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Settings',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.045 > 20 ? 20 : screenWidth * 0.045,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF202422),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                // Form Fields
                                SettingsFormField(
                                  label: 'Username',
                                  controller: usernameController,
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                SettingsFormField(
                                  label: 'Phone',
                                  controller: phoneController,
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                SettingsFormField(
                                  label: 'Email Address',
                                  controller: emailController,
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                // Toggles
                                SettingsToggle(
                                  label: 'Push Notifications',
                                  value: isPushNotificationsEnabled,
                                  onChanged: (value) {
                                    setState(() => isPushNotificationsEnabled = value);
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                SettingsToggle(
                                  label: 'Turn Dark Theme',
                                  value: isDarkThemeEnabled,
                                  onChanged: (value) {
                                    setState(() => isDarkThemeEnabled = value);
                                  },
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                // Update Profile Button
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF202422),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.08 > 40 ? 40 : screenWidth * 0.08,
                                        vertical: screenHeight * 0.015 > 15 ? 15 : screenHeight * 0.015,
                                      ),
                                      minimumSize: Size(screenWidth * 0.5, 40),
                                    ),
                                    child: Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: screenWidth * 0.035 > 16 ? 16 : screenWidth * 0.035,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.1 + bottomPadding + 20), // Space for bottom nav
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile Image positioned to straddle header and container
                  Positioned(
                    top: -(profileDiameter / 6), // Half above the container
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ProfileImage(
                        imagePath: 'lib/assets/profile_image.png',
                        radius: profileRadius / screenWidth, // Convert back to radius fraction
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}