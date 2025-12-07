import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import các file bạn đã tạo theo đúng cấu trúc thư mục
import 'core/constants/app_colors.dart';
import 'main_screen.dart';

void main() {
  // Đặt màu cho thanh trạng thái (Status Bar) của điện thoại để hòa vào nền ứng dụng
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Làm trong suốt thanh trạng thái
    statusBarIconBrightness: Brightness.light, // Icon pin/sóng màu trắng
  ));

  runApp(const TamAnApp());
}

class TamAnApp extends StatelessWidget {
  const TamAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tâm An', // Tên hiển thị khi đa nhiệm
      debugShowCheckedModeBanner: false, // Tắt chữ "Debug" đỏ ở góc phải
      
      // Cấu hình Theme chung cho toàn app
      theme: ThemeData(
        brightness: Brightness.dark, // Chế độ tối
        scaffoldBackgroundColor: AppColors.background, // Màu nền mặc định lấy từ file constants
        useMaterial3: true,
        fontFamily: 'Roboto', // Bạn có thể đổi font khác nếu muốn
      ),

      // Màn hình đầu tiên hiện ra khi mở App
      home: const MainScreen(),
    );
  }
}