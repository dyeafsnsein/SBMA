import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Controllers/auth_controller.dart';

class Header extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackArrowTap; // Optional back arrow callback
  final bool hideGreeting; // To hide greeting message in Transactions page

  const Header({
    Key? key,
    required this.onNotificationTap,
    this.onBackArrowTap, // Optional parameter
    this.hideGreeting = false, // Default value for hiding greeting
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final userName = authController.userModel.name;

    debugPrint('Header widget - User name: $userName');
    debugPrint(
        'Header widget - UserModel: ${authController.userModel.toMap()}');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show back arrow only if `onBackArrowTap` is provided
        if (onBackArrowTap != null)
          GestureDetector(
            onTap: onBackArrowTap,
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditionally show the greeting message based on `hideGreeting`
            if (!hideGreeting)
              Text(
                'Hi, ${userName.isEmpty ? 'User' : userName}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            if (!hideGreeting) const SizedBox(height: 4),
            if (!hideGreeting)
              const Text(
                'Good Morning',
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        // Notification icon
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF050505),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
