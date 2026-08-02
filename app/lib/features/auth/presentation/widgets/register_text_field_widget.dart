import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_input_decoration.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const RegisterTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTextStyles.registerInputLight,
      decoration: AppInputDecoration.light(
        context: context,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
