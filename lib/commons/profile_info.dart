import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String name;
  final String id;

  const ProfileInfo({
    Key? key,
    required this.name,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF202422),
          ),
        ),
        Text(
          'ID: $id',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenWidth * 0.04,
            color: const Color(0xFF202422),
          ),
        ),
      ],
    );
  }
}