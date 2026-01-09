import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF0F172A); // Deep slate blue
  static const accentColor = Color(0xFF38BDF8);  // Vibrant cyan
  static const secondaryAccent = Color(0xFF818CF8); // Soft indigo
  static const surfaceDark = Color(0xFF1E293B);
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: accentColor,
      secondary: secondaryAccent,
      surface: surfaceDark,
      onSurface: textPrimary,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      ThemeData.dark().textTheme.copyWith(
            displayLarge: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
            ),
            titleLarge: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.outfit(
              color: textSecondary,
            ),
          ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}
