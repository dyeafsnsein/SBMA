import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final List<String> iconPaths;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.iconPaths,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

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
              onTap: () => onItemTapped(index),
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
