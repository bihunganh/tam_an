import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Import core & services
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/auth_service.dart';
import 'package:tam_an/core/services/checkin_service.dart';
import 'package:tam_an/core/providers/user_provider.dart';
import 'package:tam_an/core/providers/theme_provider.dart';

// Import screens
import 'features/user_profile/screens/profile_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/input_tracking/widgets/custom_app_bar.dart';
import 'features/input_tracking/screens/history_screen.dart';
import 'features/input_tracking/screens/check_in_screen.dart';
import 'features/analytics/screens/analysis_screen.dart';

class MainScreen extends StatefulWidget {
  final bool showNavBar;
  final int initialIndex;
  final bool showLoginSuccess;

  const MainScreen({
    super.key,
    this.showNavBar = true,
    this.initialIndex = 0,
    this.showLoginSuccess = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final AuthService _authService = AuthService();

  // Định nghĩa màu Cam đào chủ đạo cho toàn app
  static const Color peachColor = Color(0xFFFF8A65);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user?.uid;
      if (userId != null) CheckInService().checkAndNotifyStreakLoss(userId);
      if (widget.showLoginSuccess) _showSuccessSnackBar();
    });
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 10), Text("Chào mừng trở lại!")]),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- 1. TRANG TRÍ PHÍA TRÊN: QUOTE & STREAK ---
  Widget _buildTopHealingSection(ThemeData theme) {
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final int todayWeekday = DateTime.now().weekday;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "“Hạnh phúc không phải là đích đến, mà là một hành trình.”",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
              height: 1.5,
            ),
          ).animate().fadeIn(duration: 1200.ms).slideY(begin: -0.2, end: 0),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            int dayNumber = index + 1;
            bool isToday = dayNumber == todayWeekday;
            bool isDone = dayNumber < todayWeekday;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? peachColor : (isToday ? peachColor.withOpacity(0.1) : Colors.transparent),
                border: Border.all(
                  color: (isDone || isToday) ? peachColor : theme.dividerColor.withOpacity(0.2),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isDone ? [BoxShadow(color: peachColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                weekDays[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: (isToday || isDone) ? FontWeight.bold : FontWeight.normal,
                  color: isDone ? Colors.white : (isToday ? peachColor : theme.textTheme.bodyLarge?.color?.withOpacity(0.4)),
                ),
              ),
            );
          }),
        ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
      ],
    );
  }

  // --- 2. NÚT CHECK-IN NHỊP THỞ (ĐÃ ĐỒNG BỘ CAM ĐÀO) ---
  Widget _buildBreathingButton(ThemeData theme) {
    return Animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.08, 1.08), duration: 2.seconds, curve: Curves.easeInOut)],
      child: GestureDetector(
        onTap: () => AppRouter.push(context, const CheckInScreen()),
        child: Container(
          width: 210, height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [peachColor, Color(0xFFFFAB91)], // Gradient từ cam đào sang cam nhạt
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: peachColor.withOpacity(0.4), blurRadius: 40, spreadRadius: 8),
            ],
          ),
          child: const Center(
            child: Text(
              "CHECK-IN",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ),
        ),
      ),
    );
  }

  // --- 3. NỘI DUNG CHÍNH ---
  Widget _buildHomeContent(ThemeData theme, dynamic user) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildTopHealingSection(theme),
          const SizedBox(height: 60),
          Text(
            user == null ? "Chào bạn," : "Chào ${user.username},",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color, letterSpacing: -0.5),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            "Hôm nay bạn cảm thấy thế nào?",
            style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6)),
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
          const SizedBox(height: 40),
          _buildBreathingButton(theme),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        actionWidget: _buildUserIcon(theme, user),
        onLogoTap: () => setState(() => _selectedIndex = 0),
      ),
      body: Stack(
        children: [
          // Hiệu ứng Blob nền cho cả 2 chế độ
          Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: peachColor.withOpacity(0.15)))),
          Positioned(bottom: 100, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: peachColor.withOpacity(0.1)))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container(color: Colors.transparent)),

          SafeArea(
            bottom: false,
            child: _selectedIndex == 0
                ? _buildHomeContent(theme, user)
                : _buildCurrentScreen(user),
          ),
        ],
      ),
      bottomNavigationBar: widget.showNavBar ? _buildGlassBottomBar(theme) : null,
    );
  }

  // --- CÁC PHẦN PHỤ TRỢ ---
  Widget _buildGlassBottomBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 70,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: peachColor, // Tab được chọn luôn có màu Cam đào
            unselectedItemColor: theme.hintColor.withOpacity(0.4),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 28), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded, size: 28), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.insights_rounded, size: 28), label: ''),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserIcon(ThemeData theme, dynamic user) {
    if (user == null) return const SizedBox();
    return GestureDetector(
      onTap: () => AppRouter.push(context, ProfileScreen(user: user)), // Nhấn vào là đi sửa hồ sơ luôn
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: peachColor.withOpacity(0.5), width: 1.5)),
        child: CircleAvatar(
          radius: 18, backgroundColor: Colors.grey[300],
          backgroundImage: (user.avatarUrl?.isNotEmpty ?? false)
              ? (user.avatarUrl!.startsWith('http') ? CachedNetworkImageProvider(user.avatarUrl!) : MemoryImage(base64Decode(user.avatarUrl!)) as ImageProvider)
              : null,
          child: (user.avatarUrl?.isEmpty ?? true) ? Text(user.username[0].toUpperCase(), style: const TextStyle(fontSize: 12)) : null,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(dynamic user) {
    switch (_selectedIndex) {
      case 1: return const HistoryScreen();
      case 2: return const AnalysisScreen();
      default: return const SizedBox.shrink();
    }
  }
}