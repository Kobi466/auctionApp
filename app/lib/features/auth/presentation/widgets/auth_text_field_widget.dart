import 'package:flutter/material.dart';
import '../../../../core/theme/app_input_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;

  const AuthTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTextStyles.inputText,
      decoration: AppInputDecoration.auth(
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}