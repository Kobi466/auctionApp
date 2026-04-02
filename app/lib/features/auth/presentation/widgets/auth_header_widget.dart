import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(
          Icons.shield_outlined,
          color: AppColors.gold,
          size: 34,
        ),
        SizedBox(height: 22),
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTextStyles.welcomeTitle,
        ),
        SizedBox(height: 10),
        Text(
          'ELITE ACCESS SECURED',
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}