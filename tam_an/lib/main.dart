import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 1. Import SharedPrefs

// Import các file core
import 'core/constants/app_colors.dart';
import 'core/providers/user_provider.dart';

// Import các màn hình
import 'main_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/auth_system/screens/signup_screen.dart';
import 'features/onboarding/onboarding_screen.dart'; // 2. Import Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khóa màn hình dọc (Optional - giúp giao diện không bị vỡ)
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

  // 3. LOGIC KIỂM TRA ONBOARDING
  final prefs = await SharedPreferences.getInstance();
  // Lấy trạng thái 'onboarding_seen'. Nếu chưa có (null) thì mặc định là false (chưa xem)
  final bool isOnboardingCompleted = prefs.getBool('onboarding_seen') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUser(),
      // Truyền trạng thái vào App. Nếu ĐÃ xem rồi thì showOnboarding = false
      child: TamAnApp(showOnboarding: !isOnboardingCompleted),
    ),
  );
}

class TamAnApp extends StatelessWidget {
  final bool showOnboarding; // Biến nhận trạng thái

  const TamAnApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tâm An',
      debugShowCheckedModeBanner: false,

      // Cấu hình Theme
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
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: const StadiumBorder()
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // 4. QUYẾT ĐỊNH MÀN HÌNH KHỞI ĐỘNG
      // Nếu cần show Onboarding -> Vào OnboardingScreen
      // Nếu không -> Vào MainScreen (MainScreen sẽ tự check login hay chưa)
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),

      routes: {
        '/home': (context) => const MainScreen(showNavBar: false),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}