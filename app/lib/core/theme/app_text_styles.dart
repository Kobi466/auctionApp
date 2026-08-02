import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle welcomeTitle = TextStyle(
    color: AppColors.white,
    fontSize: 42,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  static const TextStyle subtitle = TextStyle(
    color: AppColors.gold,
    fontSize: 14,
    letterSpacing: 4.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle label = TextStyle(
    color: AppColors.gold,
    fontSize: 13,
    letterSpacing: 3.5,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle inputText = TextStyle(
    color: AppColors.hint,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle forgotText = TextStyle(
    color: AppColors.gold,
    fontSize: 13,
    letterSpacing: 2.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle loginButton = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 4,
  );

  static const TextStyle registerMuted = TextStyle(
    color: AppColors.muted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle registerLink = TextStyle(
    color: AppColors.gold,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle faceIdText = TextStyle(
    color: AppColors.gold,
    fontSize: 14,
    letterSpacing: 4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle encryptedFooter = TextStyle(
    color: AppColors.goldDark,
    fontSize: 13,
    letterSpacing: 4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle errorStyle = TextStyle(
    color: AppColors.error,
    fontSize: 12,
  );

  static const TextStyle registerTitleLight = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle registerSubtitleLight = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle registerLabelLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle registerInputLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle registerButtonLight = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle registerHelperLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle registerLinkLight = TextStyle(
    color: AppColors.primaryBlue,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );
}
