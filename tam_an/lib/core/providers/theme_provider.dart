import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true; // Mặc định là tối theo thiết kế hiện tại của bạn

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Chuyển đổi qua lại giữa sáng và tối
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    // Lưu lại lựa chọn vào máy
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Tải giao diện đã lưu khi mở app
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }
}