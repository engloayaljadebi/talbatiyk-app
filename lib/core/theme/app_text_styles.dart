import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static final displayLarge = GoogleFonts.cairo(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static final displayMedium = GoogleFonts.cairo(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static final headlineLarge = GoogleFonts.cairo(
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  static final headlineMedium = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static final titleLarge = GoogleFonts.cairo(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  static final titleMedium = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static final bodyLarge = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static final bodyMedium = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final bodySmall = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static final labelLarge = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static final labelMedium = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static final labelSmall = GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
