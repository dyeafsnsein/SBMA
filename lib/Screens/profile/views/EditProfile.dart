import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/profile_controller.dart';
import 'custom_header.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ChangeNotifierProvider(
      create: (_) => EditProfileController(),
      child: Consumer<EditProfileController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const CustomHeader(title: 'Edit Profile'),
                  if (controller.isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: screenHeight * 0.03),
                              Text(
                                'Account Settings',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.045 > 20 ? 20 : screenWidth * 0.045,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              
                              // Authentication provider info message
                              if (controller.isGoogleUser)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                  child: Container(
                                    padding: EdgeInsets.all(screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.blue,
                                          size: screenWidth * 0.05,
                                        ),
                                        SizedBox(width: screenWidth * 0.02),
                                        Expanded(
                                          child: Text(
                                            'You\'re signed in with Google. Only your username can be modified.',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.blue[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                              SizedBox(height: screenHeight * 0.015),
                              // Username Field
                              TextField(
                                style: const TextStyle(color: Colors.black),
                                controller: controller.usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'John Smith',
                                  errorText: controller.usernameErrorMessage,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  filled: true,
                                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                                  labelStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(148, 146, 146, 1),
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              // Email Address Field
                              TextField(
                                style: const TextStyle(color: Colors.black),
                                controller: controller.emailController,
                                enabled: !controller.isGoogleUser,
                                decoration: InputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'example@example.com',
                                  errorText: controller.emailErrorMessage,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  filled: true,
                                  fillColor: controller.isGoogleUser 
                                      ? Colors.grey[200] 
                                      : const Color.fromARGB(255, 255, 255, 255),
                                  labelStyle: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: controller.isGoogleUser ? Colors.grey[600] : null,
                                  ),
                                  hintStyle: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(148, 146, 146, 1),
                                  ),
                                  suffixIcon: controller.isGoogleUser 
                                      ? Icon(Icons.lock, color: Colors.grey[600]) 
                                      : null,
                                ),
                              ),
                              
                              // Only show password fields for email/password users
                              if (!controller.isGoogleUser) ...[
                                SizedBox(height: screenHeight * 0.015),
                                // Password Field
                                TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: controller.passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: '••••••••',
                                    errorText: controller.passwordErrorMessage,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(148, 146, 146, 1),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                // Confirm Password Field
                                TextField(
                                  style: const TextStyle(color: Colors.black),
                                  controller: controller.confirmPasswordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    hintText: '••••••••',
                                    errorText: controller.confirmPasswordErrorMessage,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    filled: true,
                                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    hintStyle: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(148, 146, 146, 1),
                                    ),
                                  ),
                                ),
                              ],
                              if (controller.errorMessage != null)
                                Padding(
                                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                                  child: Text(
                                    controller.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              SizedBox(height: screenHeight * 0.03),
                              // Update Profile Button
                              Center(
                                child: ElevatedButton(
                                  onPressed: controller.isLoading
                                      ? null
                                      : () => controller.updateProfile(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
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
                              SizedBox(height: screenHeight * 0.1 + bottomPadding + 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}