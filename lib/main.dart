import 'package:flutter/material.dart';
import 'Views/pages/Home.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set Poppins as the default font (ensure you’ve added it in pubspec.yaml)
        fontFamily: 'Poppins',
        // Global dark grey background color
        scaffoldBackgroundColor: const Color(0xFF202422),
      ),
      home: const Home(),
    );
  }
}
