import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../Controllers/auth_controller.dart';
import '../../../commons/form_validators.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider.value(
      value: authController,
      child: _SignupForm(),
    );
  }
}

class _SignupForm extends StatefulWidget {
  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? dobError;
  String? mobileError;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AuthController>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildHeader(),
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
                                _buildNameField(controller),
                                const SizedBox(height: 20),
                                _buildEmailField(controller),
                                const SizedBox(height: 20),
                                _buildPasswordField(controller),
                                const SizedBox(height: 20),
                                _buildConfirmPasswordField(controller),
                                const SizedBox(height: 20),
                                _buildDateOfBirthField(controller, context),
                                const SizedBox(height: 20),
                                _buildMobileNumberField(controller),
                                const SizedBox(height: 30),
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
                                _buildSignUpButton(controller, context),
                                const SizedBox(height: 20),
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
          style: const TextStyle(color: Colors.black),
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'John Doe',
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
            errorText: nameError,
          ),
          onChanged: (value) {
            setState(() {
              nameError = FormValidators.validateName(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildEmailField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: controller.emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@example.com',
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
            errorText: emailError,
          ),
          onChanged: (value) {
            setState(() {
              emailError = FormValidators.validateEmail(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: controller.passwordController,
          obscureText: !controller.isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '**********',
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
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            errorText: passwordError,
          ),
          onChanged: (value) {
            setState(() {
              passwordError = FormValidators.validatePassword(value);
              // Also update confirm password error if needed
              confirmPasswordError = FormValidators.validateConfirmPassword(
                value, controller.confirmPasswordController.text);
            });
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: controller.confirmPasswordController,
          obscureText: !controller.isConfirmPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: '**********',
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
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            errorText: confirmPasswordError,
          ),
          onChanged: (value) {
            setState(() {
              confirmPasswordError = FormValidators.validateConfirmPassword(
                controller.passwordController.text, value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField(AuthController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: controller.dateOfBirthController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            hintText: 'DD/MM/YYYY',
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
            errorText: dobError,
            suffixIcon: IconButton(
              icon: const Icon(
                Icons.calendar_today,
                color: Color.fromRGBO(0, 0, 0, 1),
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
                  setState(() {
                    dobError = FormValidators.validateDateOfBirth(formattedDate);
                  });
                }
              },
            ),
          ),
          onChanged: (value) {
            setState(() {
              dobError = FormValidators.validateDateOfBirth(value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildMobileNumberField(AuthController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: controller.mobileNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '+21612345678',
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
            errorText: mobileError,
          ),
          onChanged: (value) {
            setState(() {
              mobileError = FormValidators.validateMobileNumber(value);
            });
          },
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
