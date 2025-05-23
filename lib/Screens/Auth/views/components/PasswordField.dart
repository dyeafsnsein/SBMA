import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  final String label;
  final bool isVisible;
  final Function(bool) onVisibilityChanged;
  final TextEditingController controller;

  const PasswordField({
    Key? key,
    required this.label,
    required this.isVisible,
    required this.onVisibilityChanged,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            labelText: label,
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
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.black.withAlpha((0.45 * 255).toInt()),
              ),
              onPressed: () => onVisibilityChanged(!isVisible),
            ),
          ),
        ),
      ],
    );
  }
}
