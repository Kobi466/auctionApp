import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AuthHeaderWidget extends StatelessWidget {
  const AuthHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.account_balance_wallet_rounded,
          color: AppColors.primaryBlue,
          size: 60,
        ),
        const SizedBox(height: 24),
        AppText(
          'Đăng nhập',
          textAlign: TextAlign.center,
          style: AppTextStyles.registerTitleLight,
        ),
        const SizedBox(height: 8),
        AppText(
          'Chào mừng trở lại với ReBid',
          textAlign: TextAlign.center,
          style: AppTextStyles.registerSubtitleLight,
        ),
      ],
    );
  }
}
