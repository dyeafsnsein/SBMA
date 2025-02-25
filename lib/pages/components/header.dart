import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const Header({Key? key, required this.onNotificationTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hi, Welcome Back',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            SizedBox(height: 4),
            Text(
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
