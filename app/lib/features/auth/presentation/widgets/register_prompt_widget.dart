import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterPromptWidget extends StatelessWidget {
  final VoidCallback onRegister;

  const RegisterPromptWidget({
    super.key,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Bạn chưa có tài khoản?  ",
          style: AppTextStyles.registerMuted,
        ),
        GestureDetector(
          onTap: onRegister,
          child: const Text(
            'Đăng ký',
            style: AppTextStyles.registerLink,
          ),
        ),
      ],
    );
  }
}