import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.crimson,
        surface: AppColors.surface,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: 'MatchaMint',
            fontSize: 9,
            color: states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.iconInactive,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.textPrimary
                : AppColors.iconInactive,
          );
        }),
      ),
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28),
        headlineMedium: TextStyle(fontSize: 24),
        titleLarge: TextStyle(fontSize: 18),
        titleMedium: TextStyle(fontSize: 14),
        titleSmall: TextStyle(fontSize: 13),
        headlineSmall: TextStyle(
          // Títulos principais
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(
          // Textos principais
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        bodyMedium: TextStyle(
          // Textos secundarios e descrições
          color: AppColors.textSecondary,
          fontSize: 13,
          fontFamily: 'Montserrat',
        ),
        labelLarge: TextStyle(
          // Texto de botões e labels
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: TextStyle(color: AppColors.textSecondary),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: TextStyle(color: AppColors.crimson),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.crimson),
        ),
      ),
    );
  }
}
