import 'package:flutter/material.dart';

class FormField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;

  const FormField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            labelStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black.withAlpha((0.45 * 255).toInt()),
            ),
          ),
        ),
      ],
    );
  }
}
