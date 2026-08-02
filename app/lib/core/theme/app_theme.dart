import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightText,
      ),
      inputDecorationTheme: const InputDecorationTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightText,
      ),
      cardTheme: const CardThemeData(color: AppColors.lightSurface),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.white,
        onSurfaceVariant: Color(0xFFB8C0CC),
        outline: Color(0xFF59616D),
        outlineVariant: Color(0xFF303844),
        surfaceContainerHighest: Color(0xFF1B1B1B),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.white,
      ),
      cardTheme: const CardThemeData(color: AppColors.surface),
      dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
      ),
    );
  }
}
