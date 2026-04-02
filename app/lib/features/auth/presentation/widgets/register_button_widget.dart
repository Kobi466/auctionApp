import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterButtonWidget extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const RegisterButtonWidget({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.7),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Text(
          'Đăng ký',
          style: AppTextStyles.registerButtonLight,
        ),
      ),
    );
  }
}