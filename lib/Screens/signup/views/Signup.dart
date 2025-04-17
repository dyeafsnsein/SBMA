import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/auth_controller.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: const Color(0xFF202422),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Header Section
                            _buildHeader(),
                            // Form Section
                            Expanded(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 60),
                                      // Name Field
                                      _buildNameField(controller),
                                      const SizedBox(height: 20),
                                      // Email Field
                                      _buildEmailField(controller),
                                      const SizedBox(height: 20),
                                      // Password Field
                                      _buildPasswordField(controller),
                                      const SizedBox(height: 20),
                                      // Confirm Password Field
                                      _buildConfirmPasswordField(controller),
                                      const SizedBox(height: 20),
                                      // Date of Birth Field
                                      _buildDateOfBirthField(controller, context),
                                      const SizedBox(height: 20),
                                      // Mobile Number Field
                                      _buildMobileNumberField(controller),
                                      const SizedBox(height: 30),
                                      // Error Message
                                      if (controller.errorMessage != null) ...[
                                        Text(
                                          controller.errorMessage!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                      // Sign Up Button
                                      _buildSignUpButton(controller, context),
                                      const SizedBox(height: 20),
                                      // Login Link
                                      _buildLoginLink(context),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 100, bottom: 20),
      child: const Text(
        'Create Account',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildNameField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(0, 0, 0, 0.45),
            ),
          ),
        ),
        if (controller.nameErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.nameErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmailField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(0, 0, 0, 0.45),
            ),
          ),
        ),
        if (controller.emailErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.emailErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.passwordController,
          obscureText: !controller.isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color.fromRGBO(0, 0, 0, 0.45),
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
          ),
        ),
        if (controller.passwordErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.passwordErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.confirmPasswordController,
          obscureText: !controller.isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: const Color.fromRGBO(0, 0, 0, 0.45),
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
          ),
        ),
        if (controller.confirmPasswordErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.confirmPasswordErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateOfBirthField(AuthController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.dateOfBirthController,
          readOnly: true, // Make it read-only to use the date picker
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'DD/MM/YYYY',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(0, 0, 0, 0.45),
            ),
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Color.fromRGBO(0, 0, 0, 0.45),
              ),
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  String formattedDate =
                      '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
                  controller.dateOfBirthController.text = formattedDate;
                }
              },
            ),
          ),
        ),
        if (controller.dateOfBirthErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.dateOfBirthErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileNumberField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.mobileNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '+21612345678',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(0, 0, 0, 0.45),
            ),
          ),
        ),
        if (controller.mobileNumberErrorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              controller.mobileNumberErrorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignUpButton(AuthController controller, BuildContext context) {
    return SizedBox(
      width: 210,
      child: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
              onPressed: () => controller.signUp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF202422),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.go('/login');
      },
      child: const Text(
        'Already have an account? Log In',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'League Spartan',
          fontWeight: FontWeight.w300,
          fontSize: 13,
        ),
      ),
    );
  }
}