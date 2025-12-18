import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';
import 'main_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  

  await initializeDateFormatting();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      routes: {
        '/home': (context) => const MainScreen(showNavBar: false),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}