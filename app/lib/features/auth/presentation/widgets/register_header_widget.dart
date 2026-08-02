import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: AppColors.primaryBlue,
            size: 34,
          ),
        ),
        const SizedBox(height: 20),
        AppText(
          'Create Account',
          textAlign: TextAlign.center,
          style: AppTextStyles.registerTitleLight,
        ),
        const SizedBox(height: 10),
        AppText(
          'Đăng ký tài khoản để truy cập hệ thống đấu giá,\nquản lý hồ sơ và theo dõi phiên đấu giá của bạn.',
          textAlign: TextAlign.center,
          style: AppTextStyles.registerSubtitleLight,
        ),
      ],
    );
  }
}
