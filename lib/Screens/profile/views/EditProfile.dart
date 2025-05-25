import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/profile_controller.dart';
import '../../../Controllers/auth_controller.dart';
import '../../../commons/form_validators.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: ChangeNotifierProvider(
        create: (_) => EditProfileController(),
        child: Consumer<EditProfileController>(
          builder: (context, controller, child) {
            return Scaffold(
              backgroundColor: const Color(0xFF202422),
              body: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header section with dark background
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.06,
                      ),
                      color: const Color(0xFF202422),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (controller.isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: screenWidth * 0.06,
                                  right: screenWidth * 0.06,
                                  top: screenWidth * 0.06,
                                  bottom: bottomPadding,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Account Settings',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: screenWidth * 0.045 > 20
                                            ? 20
                                            : screenWidth * 0.045,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),

                                    // Authentication provider info message
                                    if (controller.isGoogleUser)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.01),
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              screenWidth * 0.03),
                                          decoration: BoxDecoration(
                                            color: Colors.blue
                                                .withAlpha((0.1 * 255).toInt()),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.blue.withAlpha(
                                                    (0.3 * 255).toInt())),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue,
                                                size: screenWidth * 0.05,
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.02),
                                              Expanded(
                                                child: Text(
                                                  'You\'re signed in with Google. Only your username can be modified.',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize:
                                                        screenWidth * 0.035,
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
                                    _buildTextField(
                                      controller: controller.usernameController,
                                      labelText: 'Username',
                                      hintText: 'John Smith',
                                      errorText: usernameError,
                                      onChanged: (value) {
                                        setState(() {
                                          usernameError = FormValidators.validateName(value);
                                        });
                                      },
                                    ),
                                    SizedBox(height: screenHeight * 0.015),
                                    // Email Address Field
                                    _buildTextField(
                                      controller: controller.emailController,
                                      labelText: 'Email Address',
                                      hintText: 'example@example.com',
                                      errorText: emailError,
                                      enabled: !controller.isGoogleUser,
                                      fillColor: controller.isGoogleUser
                                          ? Colors.grey[200]
                                          : const Color.fromARGB(255, 255, 255, 255),
                                      labelStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: controller.isGoogleUser ? Colors.grey[600] : null,
                                      ),
                                      suffixIcon: controller.isGoogleUser
                                          ? Icon(Icons.lock, color: Colors.grey[600])
                                          : null,
                                      onChanged: (value) {
                                        if (!controller.isGoogleUser) {
                                          setState(() {
                                            emailError = FormValidators.validateEmail(value);
                                          });
                                        }
                                      },
                                    ),

                                    // Only show password fields for email/password users
                                    if (!controller.isGoogleUser) ...[
                                      SizedBox(height: screenHeight * 0.015),
                                      // Password Field
                                      _buildTextField(
                                        controller: controller.passwordController,
                                        labelText: 'New Password',
                                        hintText: '••••••••',
                                        errorText: passwordError,
                                        obscureText: true,
                                        onChanged: (value) {
                                          setState(() {
                                            passwordError = FormValidators.validatePassword(value);
                                            confirmPasswordError = FormValidators.validateConfirmPassword(
                                              value, controller.confirmPasswordController.text);
                                          });
                                        },
                                      ),
                                      SizedBox(height: screenHeight * 0.015),
                                      // Confirm Password Field
                                      _buildTextField(
                                        controller: controller.confirmPasswordController,
                                        labelText: 'Confirm Password',
                                        hintText: '••••••••',
                                        errorText: confirmPasswordError,
                                        obscureText: true,
                                        onChanged: (value) {
                                          setState(() {
                                            confirmPasswordError = FormValidators.validateConfirmPassword(
                                              controller.passwordController.text, value);
                                          });
                                        },
                                      ),
                                    ],
                                    if (controller.errorMessage != null)
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: screenHeight * 0.02),
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
                                            : () async {
                                                final updated = await controller.updateProfile(context);
                                                if (updated) {
                                                  // Refresh AuthController so Home page header updates immediately
                                                  final authController = Provider.of<AuthController>(context, listen: false);
                                                  await authController.loadCurrentUser();
                                                  if (mounted) Navigator.pop(context);
                                                }
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF202422),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.08 > 40
                                                ? 40
                                                : screenWidth * 0.08,
                                            vertical: screenHeight * 0.015 > 15
                                                ? 15
                                                : screenHeight * 0.015,
                                          ),
                                          minimumSize:
                                              Size(screenWidth * 0.5, 40),
                                        ),
                                        child: Text(
                                          'Update Profile',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: screenWidth * 0.035 > 16
                                                ? 16
                                                : screenWidth * 0.035,
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
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? errorText,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
    Color? fillColor,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      style: const TextStyle(color: Colors.black),
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        filled: true,
        fillColor: fillColor ?? const Color.fromARGB(255, 255, 255, 255),
        labelStyle: labelStyle ?? const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        hintStyle: hintStyle ?? const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(148, 146, 146, 1),
        ),
        suffixIcon: suffixIcon,
      ),
      onChanged: onChanged,
    );
  }
}
