import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class EncryptedFooterWidget extends StatelessWidget {
  const EncryptedFooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 34),
        _FooterDivider(),
        SizedBox(height: 34),
        Text(
          'END-TO-END ENCRYPTED VAULT',
          textAlign: TextAlign.center,
          style: AppTextStyles.encryptedFooter,
        ),
      ],
    );
  }
}

class _FooterDivider extends StatelessWidget {
  const _FooterDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 1.2,
      color: AppColors.border,
    );
  }
}