import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import các file core
import 'core/constants/app_colors.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/theme_provider.dart'; // Đảm bảo bạn đã tạo file này

// Import các màn hình
import 'main_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa màn hình dọc
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Khởi tạo định dạng ngày tháng
  await initializeDateFormatting();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // LOGIC KIỂM TRA ONBOARDING & THEME
  final prefs = await SharedPreferences.getInstance();
  final bool isOnboardingCompleted = prefs.getBool('onboarding_seen') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Quản lý Sáng/Tối
      ],
      // Truyền trạng thái vào App
      child: TamAnApp(showOnboarding: !isOnboardingCompleted),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  final bool showOnboarding;

  const TamAnApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái từ ThemeProvider
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,

      // --- CẤU HÌNH THEME SÁNG (Dựa trên Ảnh 2) ---
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF3366FF), // Màu xanh chủ đạo ở Ảnh 2
          secondary: Color(0xFF5C85FF),
          surface: Color(0xFFF5F7FA),
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF3366FF),
          unselectedItemColor: Colors.grey,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3366FF),
              foregroundColor: Colors.white,
              shape: const StadiumBorder()
          ),
        ),
      ),

      // --- CẤU HÌNH THEME TỐI (Giữ nguyên từ code cũ của bạn - Ảnh 1) ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFE14D), // Màu vàng nút bấm ở Ảnh 1
          secondary: AppColors.primaryBlueLight,
          background: AppColors.background,
          surface: Color(0xFF1B1B1C),
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1B1B1C),
          selectedItemColor: Color(0xFFFFE14D),
          unselectedItemColor: Colors.white70,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE14D),
              foregroundColor: Colors.black,
              shape: const StadiumBorder()
          ),
        ),
      ),

      // Quyết định dùng Theme nào dựa trên Provider
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),

      routes: {
        '/home': (context) => const MainScreen(showNavBar: false),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}