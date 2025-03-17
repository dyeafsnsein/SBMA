import 'package:flutter/material.dart';
import '../../../shared_components/custom_header.dart';
import 'package:go_router/go_router.dart';

class ChangePin extends StatefulWidget {
  const ChangePin({Key? key}) : super(key: key);

  @override
  _ChangePinState createState() => _ChangePinState();
}

class _ChangePinState extends State<ChangePin> {
  final TextEditingController currentPinController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();
  final TextEditingController confirmPinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: Column(
        children: [
          const CustomHeader(title: 'Change Pin'),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  _buildPinField('Current Pin', currentPinController),
                  SizedBox(height: screenHeight * 0.015), // Reduced spacing
                  _buildPinField('New Pin', newPinController),
                  SizedBox(height: screenHeight * 0.015), // Reduced spacing
                  _buildPinField('Confirm Pin', confirmPinController),
                  SizedBox(height: screenHeight * 0.03), // Reduced spacing
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
       context.push('/success');                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202422),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.015, // Reduced padding
                        ),
                      ),
                      child: Text(
                        'Change Pin',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: screenWidth * 0.04,
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
    );
  }

  Widget _buildPinField(String label, TextEditingController controller) {
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
        SizedBox(height: screenHeight * 0.005), // Reduced spacing
        Container(
          height: screenHeight * 0.06, // Set fixed height for the input field
          child: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF202422),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: screenHeight * 0.0 , horizontal: screenHeight * 0.02),
              hintText: '••••',
              hintStyle: TextStyle(
                fontSize: screenWidth * 0.1,
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