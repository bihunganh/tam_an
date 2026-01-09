import 'package:flutter/material.dart';

class AppColors {
  // --- DARK THEME COLORS (Giữ nguyên của bạn) ---
  static const Color background = Color(0xFF0B0B0C);
  static const Color primaryBlue = Color(0xFF0A84FF);
  static const Color primaryBlueLight = Color(0xFF5AC8FA);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFBFC8D8);
  static const Color buttonDark = Color(0xFF111214);
  static const Color successGreen = Color(0xFF34C759);
  static const Color cardColor = Color.fromARGB(255, 35, 35, 35);
  static const Color darkBg = Color(0xFF1A1A1A);
  static const Color darkPrimary = Color(0xFFFFE14D);

  // --- LIGHT THEME COLORS (Giữ nguyên của bạn) ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF3366FF);

  // --- MOOD PALETTE (Giữ nguyên của bạn) ---
  static const Color moodMad = Color(0xFFFF3B30);
  static const Color moodSad = Color.fromARGB(255, 255, 0, 179);
  static const Color moodNeutral = Color(0xFF5AC8FA);
  static const Color moodHappy = Color(0xFF4CD964);
  static const Color moodFun = Color(0xFFFF9500);
  static const Color moodAnxiety = Color(0xFFAF52DE);
  static const Color moodHappyPink = Color(0xFFFF2D55); // Hồng rực rỡ cho Hạnh phúc
  static const Color moodSadRain = Color(0xFF5E72E4);

  // =========================================================
  // --- NEW: HEALING & GLASSMORPHISM COLORS (Dành cho UI mới) ---
  // =========================================================

  // 1. Gradients cho nút bấm và nền
  static const LinearGradient zenGradient = LinearGradient(
    colors: [Color(0xFF3366FF), Color(0xFF5AC8FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nightGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0B0B0C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 2. Màu sắc cho các đốm màu nền (Blobs)
  static Color blobLightBlue = const Color(0xFF3366FF).withOpacity(0.12);
  static Color blobPurple = const Color(0xFFAF52DE).withOpacity(0.1);
  static Color blobYellow = const Color(0xFFFFE14D).withOpacity(0.08);

  // 3. Màu sắc cho hiệu ứng kính mờ (Glass)
  static Color glassWhite = Colors.white.withOpacity(0.7);
  static Color glassBlack = Colors.black.withOpacity(0.3);
  static Color glassBorder = Colors.white.withOpacity(0.2);
}