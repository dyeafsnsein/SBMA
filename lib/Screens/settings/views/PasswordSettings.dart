import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared_components/custom_header.dart';

class PasswordSettings extends StatefulWidget {
  const PasswordSettings({Key? key}) : super(key: key);

  @override
  _PasswordSettingsState createState() => _PasswordSettingsState();
}

class _PasswordSettingsState extends State<PasswordSettings> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        bottom: false, // Allow content to extend under bottom nav
        child: Column(
          children: [
            const CustomHeader(title: 'Password Settings'),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.08),
                        _buildPasswordField('Current Password', currentPasswordController),
                        SizedBox(height: screenHeight * 0.015),
                        _buildPasswordField('New Password', newPasswordController),
                        SizedBox(height: screenHeight * 0.015),
                        _buildPasswordField('Confirm New Password', confirmPasswordController),
                        SizedBox(height: screenHeight * 0.03),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/success3');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF202422),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1,
                                vertical: screenHeight * 0.015,
                              ),
                              minimumSize: Size(screenWidth * 0.5, 40),
                            ),
                            child: Text(
                              'Change Password',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.1 + bottomPadding + 20), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.04,
            color: const Color(0xFF202422),
          ),
        ),
        SizedBox(height: screenHeight * 0.005),
        Container(
          height: screenHeight * 0.06, // Set fixed height for the input field
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF202422),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.0,
                horizontal: screenHeight * 0.02,
              ),
              hintText: '••••••••',
              hintStyle: TextStyle(
                fontSize: screenWidth * 0.08,
                color: Colors.grey,
              ),
            ),
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}