import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppInputDecoration {
  static InputDecoration auth({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.inputText.copyWith(
        color: AppColors.hint.withOpacity(0.95),
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 22,
      ),
      suffixIcon: suffixIcon,
      errorStyle: AppTextStyles.errorStyle,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(
          color: AppColors.gold,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.4,
        ),
      ),
    );
  }

  static InputDecoration light({
    required String hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTextStyles.registerInputLight.copyWith(
        color: AppColors.lightHint,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: AppColors.lightSurface,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      errorStyle: AppTextStyles.errorStyle,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.4,
        ),
      ),
    );
  }
}