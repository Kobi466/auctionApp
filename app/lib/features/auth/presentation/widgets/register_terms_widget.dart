import 'package:app/core/localization/app_translator.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterTermsWidget extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const RegisterTermsWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10),
              child: AppText(
                'Tôi đồng ý với điều khoản sử dụng và chính sách bảo mật của hệ thống.',
                style: AppTextStyles.registerHelperLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
