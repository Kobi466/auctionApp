import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterFieldLabel extends StatelessWidget {
  final String text;

  const RegisterFieldLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.registerLabelLight,
    );
  }
}