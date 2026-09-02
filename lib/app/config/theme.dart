import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.tileBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textMain),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.textMain),
        bodyLarge: TextStyle(color: AppColors.textMain),
        bodyMedium: TextStyle(color: AppColors.textBody),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.textMain, // Dark surface fallback
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.primary,
        surface: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(color: AppColors.textWhite),
        bodyLarge: TextStyle(color: AppColors.textWhite),
        bodyMedium: TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}
