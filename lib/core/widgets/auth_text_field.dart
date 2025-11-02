import 'package:expense_tracker/core/config/themes/styles.dart';
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    this.errorText,
    this.hintText,
    this.icon,
    this.validator,
  });
  final TextEditingController controller;
  final IconData? icon;
  final String? hintText;
  final String? errorText;
  final Function(String value)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Required Field';
        } else if (validator != null) {
          return validator!(value);
        }
        return null;
      },
      decoration: InputDecoration(
        border: inputBorder,
        errorBorder: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedErrorBorder: inputBorder,
        hintText: hintText,
        errorText: errorText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      ),
    );
  }
}
