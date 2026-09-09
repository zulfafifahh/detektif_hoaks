import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFE8EAF6),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
  );

  /// Warna kartu berdasarkan brightness
  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E1E2E)
      : Colors.white;

  static Color cardTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : AppColors.primary;

  static Color cardDesc(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? Colors.white70
      : Colors.black87;
}
