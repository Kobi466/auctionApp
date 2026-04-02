import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LoginButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButtonWidget({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppColors.gold.withOpacity(0.7),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Colors.black,
          ),
        )
            : const Text(
          'LOGIN',
          style: AppTextStyles.loginButton,
        ),
      ),
    );
  }
}