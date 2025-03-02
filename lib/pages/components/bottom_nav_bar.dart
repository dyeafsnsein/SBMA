import 'package:flutter/material.dart';
import '../Home.dart';  // Update with your app name
import '../transaction.dart';
import '../Analysis.dart';
// Import other pages you want to navigate to

class BottomNavBar extends StatelessWidget {
  final List<String> iconPaths;
  final int selectedIndex;

  const BottomNavBar({
    Key? key,
    required this.iconPaths,
    required this.selectedIndex,
  }) : super(key: key);

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return; // Prevent navigation if already on the selected page

    // Remove the current page from the stack and push the new one
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
        break;
      case 1: // Analysis
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Analysis()),
        );
        break;
      case 2: // Transactions
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Transactions()),
        );
        break;
      case 3: // Categories
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const CategoriesPage()),
        // );
        break;
      case 4: // Profile
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const ProfilePage()),
        // );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(60),
        topRight: Radius.circular(60),
      ),
      child: Container(
        height: 80,
        color: const Color(0xFF202422),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(iconPaths.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => _handleNavigation(context, index),
              child: Container(
                decoration: isSelected
                    ? BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      )
                    : null,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                child: Image.asset(
                  iconPaths[index],
                  width: 26,
                  height: 26,
                  color: isSelected ? Colors.white : const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
