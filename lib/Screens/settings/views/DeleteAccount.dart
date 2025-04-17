import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../commons/custom_header.dart';
import 'DeleteAccountConfirmationDialog.dart'; // Add this import

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({Key? key}) : super(key: key);

  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

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
            const CustomHeader(title: 'Delete Account'),
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
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          'Are You Sure You Want To Delete Your Account?',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.05 > 20 ? 20 : screenWidth * 0.05,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF202422),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202422),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This action will permanently delete all of your data, and you will not be able to recover it. Please keep the following in mind before proceeding:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              _buildBulletPoint(
                                'All your expenses, income and associated transactions will be eliminated.',
                                screenWidth,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              _buildBulletPoint(
                                'You will not be able to access your account or any related information.',
                                screenWidth,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              _buildBulletPoint(
                                'This action cannot be undone.',
                                screenWidth,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Text(
                          'Please Enter Your Password To Confirm Deletion Of Your Account.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                            color: const Color(0xFF202422),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.015),
                        Container(
                          height: screenHeight * 0.06,
                          child: TextField(
                            controller: passwordController,
                            obscureText: _obscureText,
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Show the confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => const DeleteAccountConfirmationDialog(),
                                  );
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
                                  minimumSize: Size(screenWidth * 0.6, 40),
                                ),
                                child: Text(
                                  'Yes, Delete Account',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.015),
                              ElevatedButton(
                                onPressed: () {
                                  context.pop(); // Navigate back to the previous page
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.1,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  minimumSize: Size(screenWidth * 0.6, 40),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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

  Widget _buildBulletPoint(String text, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
            color: Colors.white,
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}