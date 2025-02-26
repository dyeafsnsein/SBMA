import 'package:flutter/material.dart';

class QuickAnalysisHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onNotificationTap;

  const QuickAnalysisHeader({
    Key? key,
    required this.onBackPressed,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: onBackPressed,
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        const Text(
          'Quickly Analysis',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF050505),
              borderRadius: BorderRadius.circular(25.71),
            ),
            child: const Center(
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
