import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.crimson,
        surface: AppColors.surface,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontFamily: 'Montserrat',
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
      popupMenuTheme: const PopupMenuThemeData(
        color: Color(0xF01B1B20),
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.border,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28),
        headlineMedium: TextStyle(fontSize: 24),
        titleLarge: TextStyle(fontSize: 18),
        titleMedium: TextStyle(fontSize: 14),
        titleSmall: TextStyle(fontSize: 13),
        headlineSmall: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        bodyLarge: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontFamily: 'Montserrat',
        ),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
        color: Color(0x0DFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0x08FFFFFF),
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
