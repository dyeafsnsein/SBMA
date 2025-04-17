import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final List<String> iconPaths;
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.iconPaths,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF202422),
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
      height: screenHeight * 0.1 + bottomPadding, // Responsive height
      padding: EdgeInsets.fromLTRB(
        screenHeight * 0.02, // Horizontal padding
        screenHeight * 0.015, // Top padding
        screenHeight * 0.02, // Horizontal padding
        bottomPadding + screenHeight * 0.015, // Bottom padding + safe area
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(iconPaths.length, (index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[700] : Colors.transparent,
                borderRadius: BorderRadius.circular(screenHeight * 0.025),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenHeight * 0.014,
                vertical: screenHeight * 0.011,
              ),
              child: Image.asset(
                iconPaths[index],
                width: screenHeight * 0.032,
                height: screenHeight * 0.032,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
            ),
          );
        }),
      ),
    );
  }
}