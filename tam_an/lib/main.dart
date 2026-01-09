import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tam_an/core/services/notification_service.dart';

// Import các file core
import 'core/constants/app_colors.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/theme_provider.dart';

// Import các màn hình
import 'main_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo thông báo
  final notificationService = NotificationService();
  await notificationService.init();

  // Kích hoạt các lịch nhắc nhở
  await notificationService.scheduleDailyReminder();
  await notificationService.scheduleWeeklyInsights();

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

  final prefs = await SharedPreferences.getInstance();
  final bool isOnboardingCompleted = prefs.getBool('onboarding_seen') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: TamAnApp(showOnboarding: !isOnboardingCompleted),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  final bool showOnboarding;
  // Mã màu cam đào chủ đạo đồng bộ với các màn hình khác
  static const Color peachColor = Color(0xFFFF8A65);

  const TamAnApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,

      // --- THEME SÁNG ---
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFFF9F7),
        colorScheme: ColorScheme.light(
          primary: peachColor,
          secondary: peachColor.withOpacity(0.7),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: peachColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),

      // --- THEME TỐI ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.midnightBlue,
        colorScheme: ColorScheme.dark(
          primary: peachColor,
          secondary: AppColors.darkAccent,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
        ),
      ),

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // --- ĐIỀU HƯỚNG TỰ ĐỘNG ---
      home: showOnboarding
          ? const OnboardingScreen()
          : StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: peachColor)),
            );
          }

          if (snapshot.hasData) {
            // Đã đăng nhập: Nạp dữ liệu và hiện màn hình chính CÓ NavBar
            context.read<UserProvider>().loadUser();
            return const MainScreen(showNavBar: true);
          }

          // Chưa đăng nhập
          return const LoginScreen();
        },
      ),

      routes: {
        // SỬA TẠI ĐÂY: showNavBar phải là true để hiện thanh công cụ
        '/home': (context) => const MainScreen(showNavBar: true),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}