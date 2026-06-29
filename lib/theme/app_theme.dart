import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_motion.dart';

class AppTheme {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0A0A0A);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color.fromRGBO(255, 255, 255, 0.4);
  static const Color border = Color.fromRGBO(255, 255, 255, 0.08);

  static ThemeData get dark {
    final base = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primaryText,
        secondary: secondaryText,
        onSurface: primaryText,
      ),
      textTheme: base.apply(bodyColor: primaryText, displayColor: primaryText),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: labelStyle.copyWith(color: secondaryText),
        contentPadding: const EdgeInsets.all(18),
        border: outlineInputBorder,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder.copyWith(
          borderSide: const BorderSide(color: primaryText, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primaryText,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AppPageTransitionsBuilder(),
          TargetPlatform.iOS: AppPageTransitionsBuilder(),
          TargetPlatform.macOS: AppPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder get outlineInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: border, width: 1),
    );
  }

  static TextStyle get labelStyle {
    return GoogleFonts.inter(
      color: primaryText,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 3,
    );
  }

  static TextStyle get displayStyle {
    return GoogleFonts.inter(
      color: primaryText,
      fontSize: 48,
      fontWeight: FontWeight.w700,
      letterSpacing: -2,
      height: 1,
    );
  }

  static TextStyle get bodyStyle {
    return GoogleFonts.inter(
      color: primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
  }

  static TextStyle get secondaryStyle {
    return GoogleFonts.inter(
      color: secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
    );
  }
}
