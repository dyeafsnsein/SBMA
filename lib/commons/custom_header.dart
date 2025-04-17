import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const CustomHeader({
    Key? key,
    required this.title,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding,
        left: screenWidth * 0.06,
        right: screenWidth * 0.06,
      ),
      height: screenHeight * 0.15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBackPressed ?? () => context.pop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/notification'),
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xFF050505),
                borderRadius: BorderRadius.circular(screenWidth * 0.90),
              ),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: screenWidth * 0.045,
              ),
            ),
          ),
        ],
      ),
    );
  }
}