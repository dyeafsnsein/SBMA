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
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(40), // Adjust corner radius
        topRight: Radius.circular(40),
      ),
      child: Container(
        height: 80,
        color: const Color(0xFF202422), // Ensure dark background matches the app theme
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(iconPaths.length, (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4D4D4D) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  iconPaths[index],
                  width: 26,
                  height: 26,
                  color: Colors.white, // Ensure icons are white for visibility
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
