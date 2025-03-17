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

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Edit Profile'),
          
          Expanded(
            child: Stack(
              children: [
                // White background container
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

                // Content Container
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.04),
                  child: Column(
                    children: [
                      SizedBox(height: screenWidth * 0.18),
                      const ProfileInfo(
                        name: 'John Smith',
                        id: '25030024',
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      
                      // Settings Content
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // Added this
                            children: [
                              Text(
                                'Account Settings',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.045, // Reduced font size
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF202422),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01), // Reduced spacing
                              
                              // Form Fields
                              SettingsFormField(
                                label: 'Username',
                                controller: usernameController,
                              ),
                              SizedBox(height: screenHeight * 0.005), // Reduced spacing
                              SettingsFormField(
                                label: 'Phone',
                                controller: phoneController,
                              ),
                              SizedBox(height: screenHeight * 0.005), // Reduced spacing
                              SettingsFormField(
                                label: 'Email Address',
                                controller: emailController,
                              ),
                              SizedBox(height: screenHeight * 0.005), // Reduced spacing
                              
                              // Toggles
                              SettingsToggle(
                                label: 'Push Notifications',
                                value: isPushNotificationsEnabled,
                                onChanged: (value) {
                                  setState(() => isPushNotificationsEnabled = value);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.015), // Reduced spacing
                              SettingsToggle(
                                label: 'Turn Dark Theme',
                                value: isDarkThemeEnabled,
                                onChanged: (value) {
                                  setState(() => isDarkThemeEnabled = value);
                                },
                              ),
                              SizedBox(height: screenHeight * 0.02), // Reduced spacing
                              
                              // Update Profile Button
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF202422),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15), // Reduced radius
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.08, // Reduced padding
                                      vertical: screenHeight * 0.015, // Reduced padding
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: screenWidth * 0.035, // Reduced font size
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}