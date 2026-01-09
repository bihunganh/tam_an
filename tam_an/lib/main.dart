import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart'; // Để dùng font Nunito

// Import các file core & providers
import 'core/constants/app_colors.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';

// Import các màn hình
import 'main_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cấu hình thanh trạng thái trong suốt cho Xiaomi Redmi Note 11T Pro
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // 2. Khởi tạo Thông báo
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.scheduleDailyReminder();
  await notificationService.scheduleWeeklyInsights();

  // 3. Khóa màn hình dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Khởi tạo Firebase và Định dạng ngày tháng
  await initializeDateFormatting('vi_VN', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. Kiểm tra Onboarding
  final prefs = await SharedPreferences.getInstance();
  final bool isOnboardingCompleted = prefs.getBool('onboarding_seen') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: TamAnApp(showOnboarding: !isOnboardingCompleted),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  final bool showOnboarding;

  const TamAnApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,

      // --- CẤU HÌNH THEME SÁNG (Zen Morning) ---
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        // Sử dụng font Nunito để tạo cảm giác nhẹ nhàng, chữa lành
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightPrimary,
          secondary: Color(0xFF5C85FF),
          surface: Color(0xFFF8FAFC),
          onPrimary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        // SỬA LỖI TẠI ĐÂY: Thay CardTheme bằng CardThemeData
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.lightPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),

      // --- CẤU HÌNH THEME TỐI (Deep Night) ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          secondary: AppColors.primaryBlueLight,
          surface: Color(0xFF1B1B1C),
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        // SỬA LỖI TẠI ĐÂY: Thay CardTheme bằng CardThemeData
        cardTheme: CardThemeData(
          color: const Color(0xFF1B1B1C),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),

      themeMode: themeProvider.themeMode,
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(showNavBar: true),

      routes: {
        '/home': (context) => const MainScreen(showNavBar: true),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}