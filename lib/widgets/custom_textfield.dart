import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool isDigit;
  final int maxLength;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.validator,
    this.isDigit = false,
    this.maxLength = 100
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: const Color(0xFF7F5539),
      autovalidateMode: AutovalidateMode.onUnfocus,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        counter: const SizedBox.shrink(),
        errorStyle: const TextStyle(color: Color(0xFF7F5539)),
        labelStyle: const TextStyle(color: Color(0xFF7F5539)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFDDB892), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7F5539), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7F5539), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF7F5539), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: obscureText,
      validator: validator,
      keyboardType: isDigit ? TextInputType.number : TextInputType.text,
      inputFormatters: isDigit ? [FilteringTextInputFormatter.digitsOnly] : [],
    );
  }
}
