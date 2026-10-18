import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Official Kaduna State University (KASU) Color Combination
  static const green = Color(0xFF0D5C3A); // Official KASU Deep Forest Green (Primary)
  static const darkGreen = Color(0xFF083C25); // KASU Senate Dark Green
  static const emerald = Color(0xFF15803D); // Vibrant Accent Green
  static const mint = Color(0xFFE8F5E9); // KASU Mint Surface
  static const gold = Color(0xFFD97706); // KASU Academic Gold (Secondary)
  static const lightGold = Color(0xFFFEF3C7); // KASU Gold Badge / Container
  static const accentGold = Color(0xFFD97706); // KASU Gold Accent

  // Primary brand tokens
  static const primary = Color(0xFF0D5C3A);
  static const secondary = Color(0xFFD97706);

  // Remapped tokens for existing UI components
  static const blue = Color(0xFF0D5C3A); // Remapped to KASU Deep Green
  static const teal = Color(0xFFD97706); // Remapped to KASU Warm Gold
  static const navy = Color(0xFF092016); // Remapped to KASU Deep Forest Dark

  // Neutral surfaces
  static const background = Color(0xFFF6FAF7); // Soft KASU tinted light background
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF0F1E17);
  static const textSecondary = Color(0xFF526E60);
  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const border = Color(0xFFE0EBE4); // Sage-tinted light border
}

class AppTheme {
  static const radius = 14.0;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: b,
      primary: AppColors.green,
      secondary: AppColors.gold,
      error: AppColors.error,
      surface: isDark ? const Color(0xFF0F261C) : AppColors.surface,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: isDark ? Colors.white : AppColors.text,
      displayColor: isDark ? Colors.white : AppColors.text,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
          color: isDark ? const Color(0xFF1B3D2E) : AppColors.border),
    );
    return base.copyWith(
      scaffoldBackgroundColor:
          isDark ? AppColors.navy : AppColors.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.navy : AppColors.background,
        foregroundColor: isDark ? Colors.white : AppColors.navy,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(
              color: isDark ? const Color(0xFF1B3D2E) : AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF143325) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: AppColors.green),
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: AppColors.green.withValues(alpha: 0.14),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
  }
}
