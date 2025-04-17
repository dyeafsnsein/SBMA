import 'package:flutter/material.dart';

class SettingsFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SettingsFormField({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: MediaQuery.of(context).size.width * 0.04,
            color: const Color(0xFF202422),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFE8F5E9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}