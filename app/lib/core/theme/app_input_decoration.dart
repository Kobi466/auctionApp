import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppInputDecoration {
  static InputDecoration auth({
    required BuildContext context,
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.registerInputLight.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      suffixIcon: suffixIcon,
      errorStyle: AppTextStyles.errorStyle,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
    );
  }

  static InputDecoration light({
    required BuildContext context,
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return auth(context: context, hintText: hintText, suffixIcon: suffixIcon);
  }
}
