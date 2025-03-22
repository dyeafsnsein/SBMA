import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountConfirmationDialog extends StatelessWidget {
  const DeleteAccountConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: screenWidth * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Delete Account',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.05 > 18 ? 18 : screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF202422),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Are You Sure You Want To Log Out?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.045 > 16 ? 16 : screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF202422),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'By deleting your account, you agree to the consequences of this action and that you agree to permanently delete your account and all associated data.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: screenWidth * 0.035 > 14 ? 14 : screenWidth * 0.035,
                color: const Color(0xFF202422),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.03),
            Column(
              children: [
                Container(
                  height: 50,
                  width: double.infinity, // Full width for the button
                  decoration: BoxDecoration(
                    color: const Color(0xFF202422),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    onPressed: () {
                      context.pop(); // Close the dialog
                      // Navigate to the login page after deletion
                      context.go('/login');
                    },
                    child: Text(
                      'Yes, Delete Account',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                Container(
                  height: 50,
                  width: double.infinity, // Full width for the button
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D3D3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04,
                        color: const Color(0xFF202422),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}