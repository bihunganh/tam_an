import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  // Getter để lấy ThemeMode cho MaterialApp trong main.dart
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  // --- GETTERS DÀNH RIÊNG CHO GIAO DIỆN CHỮA LÀNH ---

  // Lấy màu đốm nền (Blob) chính tùy theo theme
  Color get primaryBlobColor => _isDarkMode
      ? AppColors.darkPrimary.withOpacity(0.1)
      : AppColors.lightPrimary.withOpacity(0.12);

  // Lấy độ mờ cho hiệu ứng kính mờ (Glassmorphism)
  double get glassBlur => _isDarkMode ? 15.0 : 10.0;

  // Lấy màu nền của lớp kính
  Color get glassColor => _isDarkMode
      ? Colors.black.withOpacity(0.4)
      : Colors.white.withOpacity(0.6);

  // --- LOGIC CHUYỂN ĐỔI ---

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }
}