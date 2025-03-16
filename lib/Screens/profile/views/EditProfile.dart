import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:go_router/go_router.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Settings',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF202422),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          
                          // Username field
                          Text(
                            'Username',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFF202422),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'John Smith',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.04,
                                color: const Color(0xFF202422),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Phone field
                          Text(
                            'Phone',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFF202422),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '+44 555 5555 55',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.04,
                                color: const Color(0xFF202422),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Email field
                          Text(
                            'Email Address',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                              color: const Color(0xFF202422),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04,
                              vertical: screenHeight * 0.015,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'example@example.com',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: screenWidth * 0.04,
                                color: const Color(0xFF202422),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Push Notifications toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Push Notifications',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.04,
                                  color: const Color(0xFF202422),
                                ),
                              ),
                              Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: const Color(0xFF202422),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          
                          // Dark Theme toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Turn Dark Theme',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.04,
                                  color: const Color(0xFF202422),
                                ),
                              ),
                              Switch(
                                value: false,
                                onChanged: (value) {},
                                activeColor: const Color(0xFF202422),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          
                          // Update Profile button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {},
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
                                'Update Profile',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
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
                      radius: screenWidth * 0.13,
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
}