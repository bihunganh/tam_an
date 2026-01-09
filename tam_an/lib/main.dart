import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Thêm để kiểm tra trạng thái login
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
        // Khởi tạo UserProvider nhưng không gọi loadUser() ngay tại đây để tránh xung đột
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: TamAnApp(showOnboarding: !isOnboardingCompleted),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  final bool showOnboarding;
  static const Color peachColor = Color(0xFFFF8A65); // Mã màu cam đào chủ đạo

  const TamAnApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,

      // --- THEME SÁNG (Tone Cam đào chuyên nghiệp) ---
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFFFF9F7), // Nền cam cực nhạt
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

      // --- THEME TỐI (Giữ nguyên phong cách Midnight) ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.midnightBlue,
        colorScheme: ColorScheme.dark(
          primary: peachColor, // Dùng cam đào làm điểm nhấn cho chế độ tối
          secondary: AppColors.darkAccent,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
        ),
      ),

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // --- XỬ LÝ LUỒNG ĐIỀU HƯỚNG TỰ ĐỘNG ---
      home: showOnboarding
          ? const OnboardingScreen()
          : StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Nếu đang kiểm tra trạng thái login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: peachColor)));
          }

          // Nếu đã đăng nhập (User != null)
          if (snapshot.hasData) {
            // Gọi load dữ liệu Profile từ Provider
            context.read<UserProvider>().loadUser();
            return const MainScreen();
          }

          // Nếu chưa đăng nhập hoặc đã đăng xuất
          return const LoginScreen();
        },
      ),

      routes: {
        '/home': (context) => const MainScreen(showNavBar: false),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}