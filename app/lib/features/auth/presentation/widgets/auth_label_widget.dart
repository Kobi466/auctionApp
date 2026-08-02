import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthLabelWidget extends StatelessWidget {
  final String text;

  const AuthLabelWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AppText(text, style: AppTextStyles.registerLabelLight),
    );
  }
}
