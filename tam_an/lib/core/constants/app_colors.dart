import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primaryWarm = Color(0xFFFF9F66); // Warmer Primary
  static const Color accentWarm = Color(0xFFFFCC80);
  
  // Dark Theme Colors (Midnight Blue)
  static const Color midnightBlue = Color(0xFF0A0E21); // Deep Midnight Blue
  static const Color darkSurface = Color(0xFF1D1E33);
  static const Color darkTextPrimary = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkAccent = Color(0xFFFFD740); // Aurora/Star like gold

  // Light Theme Colors (Warm Off-White)
  static const Color warmOffWhite = Color(0xFFFDFCF0); // Soft, warm off-white
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2C2C2C);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightPrimary = Color(0xFFFF7043); // Warmer orange-ish

  // Mood Palette (Enhanced for warmth)
  static const Color moodMad = Color(0xFFE57373);
  static const Color moodSad = Color(0xFF90CAF9);
  static const Color moodNeutral = Color(0xFFAED581);
  static const Color moodHappy = Color(0xFFFFF176);
  static const Color moodFun = Color(0xFFFFB74D);
  static const Color moodAnxiety = Color(0xFFB39DDB);

  // For backward compatibility or specific uses
  static const Color background = midnightBlue;
  static const Color primaryBlue = Color(0xFF3F51B5);
  static const Color primaryBlueLight = Color(0xFF7986CB);
}