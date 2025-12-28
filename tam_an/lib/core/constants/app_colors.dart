import 'package:flutter/material.dart';

class AppColors {
  // Nền chính: gần như đen để có cảm giác tối chuyên nghiệp
  static const Color background = Color(0xFF0B0B0C);

  // Màu chủ đạo mới: Xanh dương (lấy cảm hứng từ tông Apple Health)
  static const Color primaryBlue = Color(0xFF0A84FF); // Blue chính
  static const Color primaryBlueLight = Color(0xFF5AC8FA); // Blue nhạt cho gradient / glow

  // Văn bản và layer sáng
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textLight = Color(0xFFBFC8D8); // chữ trắng mờ hơi lạnh

  // Màu nút nền tối
  static const Color buttonDark = Color(0xFF111214);

  // Màu trạng thái / thành công
  static const Color successGreen = Color(0xFF34C759);

  // Palette cảm xúc (đa sắc, lấy cảm hứng từ Apple Health)
  static const Color moodMad = Color(0xFFFF3B30);    // Đỏ
  static const Color moodSad = Color.fromARGB(255, 255, 0, 179);     // Hồng
  static const Color moodNeutral = Color(0xFF5AC8FA);    // Xanh dương nhạt
  static const Color moodHappy = Color(0xFF4CD964);      // Xanh lá
  static const Color moodFun = Color(0xFFFF9500);       // Cam
  static const Color moodAnxiety = Color(0xFFAF52DE);    // Tím
}