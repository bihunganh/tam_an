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
import 'features/input_tracking/screens/home_screen.dart';
import 'features/analytics/screens/analysis_screen.dart';

class MainScreen extends StatefulWidget {
  final bool showNavBar;
  final int initialIndex;
  final bool showLoginSuccess;

  const MainScreen({
    super.key,
    this.showNavBar = false,
    this.initialIndex = 0,
    this.showLoginSuccess = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;
  final AuthService _authService = AuthService();

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

  // --- TRANG TRÍ PHÍA TRÊN: QUOTE & STREAK (T2-CN) ---
  Widget _buildTopHealingSection(ThemeData theme) {
    final List<String> weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final int todayWeekday = DateTime.now().weekday; // 1 (Mon) -> 7 (Sun)

    return Column(
      children: [
        // 1. Câu trích dẫn chữa lành
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

        // 2. Thanh Streak với các vòng tròn chứa Thứ
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(7, (index) {
            int dayNumber = index + 1;
            bool isToday = dayNumber == todayWeekday;
            bool isDone = dayNumber < todayWeekday; // Giả định check-in các ngày trước

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? theme.colorScheme.primary
                    : (isToday ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent),
                border: Border.all(
                  color: (isDone || isToday) ? theme.colorScheme.primary : theme.dividerColor.withOpacity(0.2),
                  width: isToday ? 2 : 1,
                ),
                boxShadow: isDone ? [
                  BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))
                ] : null,
              ),
              alignment: Alignment.center,
              child: Text(
                weekDays[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: (isToday || isDone) ? FontWeight.bold : FontWeight.normal,
                  color: isDone
                      ? theme.colorScheme.onPrimary
                      : (isToday ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color?.withOpacity(0.4)),
                ),
              ),
            );
          }),
        ).animate().fadeIn(delay: 600.ms, duration: 800.ms),
      ],
    );
  }

  // --- NỘI DUNG CHÍNH TRANG HOME ---
  Widget _buildHomeContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildTopHealingSection(theme),
          const SizedBox(height: 60),

          Text(
            "Chào Hùng Anh,",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: theme.textTheme.bodyLarge?.color,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            "Hôm nay bạn cảm thấy thế nào?",
            style: TextStyle(
              fontSize: 16,
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
          const SizedBox(height: 40),

          // Nút CHECK-IN nhịp thở
          Animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            effects: [
              ScaleEffect(
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                  duration: 2.seconds,
                  curve: Curves.easeInOut
              )
            ],
            child: GestureDetector(
              onTap: () => AppRouter.push(context, const CheckInScreen()),
              child: Container(
                width: 210, height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: theme.brightness == Brightness.light
                        ? [AppColors.lightPrimary, AppColors.lightPrimary.withOpacity(0.8)]
                        : [AppColors.darkPrimary, AppColors.darkPrimary.withOpacity(0.8)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (theme.brightness == Brightness.light
                          ? AppColors.lightPrimary
                          : AppColors.darkPrimary).withOpacity(0.3),
                      blurRadius: 35, spreadRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "CHECK-IN",
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 120), // Tránh bị che bởi NavBar
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        actionWidget: _buildUserIcon(theme, user),
        onLogoTap: () => setState(() => _selectedIndex = 0),
      ),
      body: Stack(
        children: [
          // NỀN NGHỆ THUẬT (Blobs)
          Positioned(top: -100, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: themeProvider.primaryBlobColor))),
          Positioned(bottom: 100, right: -100, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: theme.colorScheme.secondary.withOpacity(0.1)))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container(color: Colors.transparent)),

          // NỘI DUNG CHÍNH
          SafeArea(
            bottom: false,
            child: _selectedIndex == 0
                ? _buildHomeContent(theme)
                : _buildCurrentScreen(user),
          ),
        ],
      ),
      bottomNavigationBar: widget.showNavBar ? _buildGlassBottomBar(theme) : null,
    );
  }

  // --- CÁC PHẦN PHỤ TRỢ (NavBar, UserIcon...) ---
  Widget _buildCurrentScreen(user) {
    switch (_selectedIndex) {
      case 1: return const HistoryScreen();
      case 2: return const AnalysisScreen();
      default: return const SizedBox.shrink();
    }
  }

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
            selectedItemColor: theme.colorScheme.primary,
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

  Widget _buildUserIcon(ThemeData theme, user) {
    if (user == null) return const SizedBox();
    return GestureDetector(
      onTapDown: (details) => _showUserMenu(details.globalPosition, theme, user),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5)),
        child: CircleAvatar(
          radius: 18, backgroundColor: Colors.grey[300],
          backgroundImage: (user.avatarUrl?.isNotEmpty ?? false) ? (user.avatarUrl!.startsWith('http') ? CachedNetworkImageProvider(user.avatarUrl!) : MemoryImage(base64Decode(user.avatarUrl!)) as ImageProvider) : null,
          child: (user.avatarUrl?.isEmpty ?? true) ? Text(user.username[0].toUpperCase(), style: const TextStyle(fontSize: 12)) : null,
        ),
      ),
    );
  }

  void _showUserMenu(Offset position, ThemeData theme, user) {
    showMenu(
      context: context, position: RelativeRect.fromLTRB(position.dx, position.dy + 20, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), color: theme.colorScheme.surface.withOpacity(0.95),
      items: [
        PopupMenuItem(onTap: () => Future.delayed(Duration.zero, () => AppRouter.push(context, ProfileScreen(user: user))), child: const ListTile(leading: Icon(Icons.person_outline), title: Text("Hồ sơ"))),
        PopupMenuItem(onTap: () => Future.delayed(Duration.zero, () => _handleLogout()), child: const ListTile(leading: Icon(Icons.logout, color: Colors.redAccent), title: Text("Đăng xuất"))),
      ],
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), title: const Text("Tạm biệt?"), content: const Text("Bạn có muốn đăng xuất khỏi Tâm An không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(onPressed: () async { Navigator.pop(context); await _authService.signOut(); if (mounted) { Provider.of<UserProvider>(context, listen: false).clear(); AppRouter.pushAndRemoveUntil(context, const LoginScreen()); }}, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), child: const Text("Đăng xuất")),
        ],
      ),
    );
  }
}