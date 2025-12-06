import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'screens/home_screen.dart'; 


void main() async {
  


  WidgetsFlutterBinding.ensureInitialized();
  
  // Database

  runApp(const TamAnApp());
}

class TamAnApp extends StatelessWidget {
  const TamAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false, 
      
      // Cấu hình Theme (Giao diện) mặc định
      theme: ThemeData(
        brightness: Brightness.dark, // Chế độ tối
        scaffoldBackgroundColor: AppColors.background, // Màu nền đen mình chọn
        primaryColor: AppColors.primary,
        
        // Cài đặt Font chữ toàn App là Inter
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
        ),
        
        // Cài đặt App Bar mặc định
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Trong suốt
          elevation: 0, // Không bóng đổ
          centerTitle: false, // Căn trái tiêu đề
        ),
      ),
      
      // Màn hình đầu tiên hiện ra
      home: const HomeScreen(),
    );
  }
}