import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class KycTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const KycTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.registerLabelLight.copyWith(
            color: AppColors.lightSubText,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: AppTextStyles.registerInputLight,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.registerInputLight.copyWith(
              color: AppColors.lightHint.withOpacity(0.5),
            ),
            filled: true,
            fillColor: const Color(0xFFE8EAF6), // Light indigo/purple as seen in screenshot
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
