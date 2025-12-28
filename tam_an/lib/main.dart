import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'main_screen.dart';
import 'core/providers/user_provider.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  

  await initializeDateFormatting();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUser(),
      child: const TamAnApp(),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  const TamAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tâm An', // Tên hiển thị khi đa nhiệm
      debugShowCheckedModeBanner: false, // Tắt chữ "Debug" đỏ ở góc phải
      
      // Cấu hình Theme chung cho toàn app (Dark + Blue accents)
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.primaryBlueLight,
          background: AppColors.background,
          surface: Color(0xFF0F0F10),
          onPrimary: Colors.white,
          onBackground: Colors.white70,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B1B1C),
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.white70,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white, shape: const StadiumBorder()),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
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