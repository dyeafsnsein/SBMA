import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // Tracks the currently selected index

  // List of icons for the navigation bar
  final List<String> _iconPaths = [
    'lib/pages/assets/Home.png',
    'lib/pages/assets/Analysis.png',
    'lib/pages/assets/Transactions.png',
    'lib/pages/assets/Categories.png',
    'lib/pages/assets/Profile.png',
  ];

  // Handles icon selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // Make status bar transparent
        statusBarIconBrightness: Brightness.light, // Set icons to light
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF202422), // Dark grey background
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Dark grey top section
                Expanded(
                  flex: 36,
                  child: Container(
                    color: const Color(0xFF202422),
                  ),
                ),
                // White container extending to bottom
                Expanded(
                  flex: 84,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3), // Light green/white box
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Bottom navigation bar layered on top
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
                child: Container(
                  height: 80, // Increased height for the navbar
                  color: const Color(0xFF202422), // Background color of bottom bar
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 2), // Space between buttons and edges
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space between buttons
                    children: List.generate(_iconPaths.length, (index) {
                      final isSelected = _selectedIndex == index;
                      return GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: Colors.grey[700], // Highlighted background for selected icon
                                  borderRadius: BorderRadius.circular(20), // Rounded rectangle shape
                                )
                              : null, // No background for unselected icons
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), // Padding inside the rectangle
                          child: Image.asset(
                            _iconPaths[index],
                            width: 26, // Icon size
                            height: 26,
                            color: isSelected ? Colors.white : const Color.fromARGB(255, 255, 255, 255), // Change icon color based on selection
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
