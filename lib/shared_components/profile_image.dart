import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String imagePath;
  final double radius;

  const ProfileImage({
    Key? key,
    required this.imagePath,
    this.radius = 0.13,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return CircleAvatar(
      radius: screenWidth * radius,
      backgroundImage: AssetImage(imagePath),
    );
  }
}