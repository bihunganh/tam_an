import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart'; // Để dùng .read<UserProvider>
import 'package:tam_an/core/services/checkin_service.dart'; // Để dùng CheckInService
import 'package:tam_an/core/providers/user_provider.dart'; // Để dùng UserProvider
import 'core/providers/user_provider.dart';
import 'core/providers/theme_provider.dart'; // Thêm import này
import 'features/user_profile/screens/profile_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/input_tracking/widgets/custom_app_bar.dart';
import 'dart:convert';

// Import các màn hình con
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
      final userId = context.read<UserProvider>().user?.uid; // Hoặc cách bạn lấy userId
      if (userId != null) {
        CheckInService().checkAndNotifyStreakLoss(userId);
      }
    });
    if (widget.showLoginSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text("Đăng nhập thành công!"),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      });
    }
  }

  // --- HÀM XỬ LÝ ĐĂNG XUẤT (Cập nhật màu Theme) ---
  void _handleLogout() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface, // Màu nền theo Theme
        title: Text("Đăng xuất", style: TextStyle(color: theme.colorScheme.primary)),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?",
            style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
              if (mounted) {
                Provider.of<UserProvider>(context, listen: false).clear();
                AppRouter.pushAndRemoveUntil(context, const LoginScreen());
              }
            },
            child: const Text("Đồng ý", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- ICON USER AppBar (Cập nhật màu Theme) ---
  Widget? _buildUserIcon() {
    final user = Provider.of<UserProvider>(context).user;
    final theme = Theme.of(context);
    if (user == null) return null;

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          AppRouter.push(context, ProfileScreen(user: user));
        } else if (value == 'logout') {
          _handleLogout();
        }
      },
      color: theme.colorScheme.surface, // Màu Popup theo theme
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(children: [
            Icon(Icons.person, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Text("Hồ sơ", style: TextStyle(color: theme.textTheme.bodyLarge?.color))
          ]),
        ),
        PopupMenuItem(
          value: 'logout',
          child: Row(children: [
            const Icon(Icons.logout, color: Colors.redAccent),
            const SizedBox(width: 10),
            Text("Đăng xuất", style: TextStyle(color: theme.textTheme.bodyLarge?.color))
          ]),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: theme.colorScheme.primary, width: 2),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[400],
          backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? (user.avatarUrl!.startsWith('http')
              ? CachedNetworkImageProvider(user.avatarUrl!)
              : MemoryImage(base64Decode(user.avatarUrl!)))
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? Text(
            user.username[0].toUpperCase(),
            style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 14),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    final user = Provider.of<UserProvider>(context).user;
    switch (_selectedIndex) {
      case 0:
        return widget.showNavBar ? const CheckInScreen() : HomeScreen(currentUser: user);
      case 1:
        return const HistoryScreen();
      case 2:
        return const AnalysisScreen();
      default:
        return HomeScreen(currentUser: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Khởi tạo theme để dùng bên dưới

    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Đổi màu nền tự động
        appBar: CustomAppBar(
          actionWidget: _buildUserIcon(),
          onLogoTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              setState(() => _selectedIndex = 0);
            }
          },
        ),

        body: SafeArea(
          child: _buildCurrentScreen(),
        ),

        bottomNavigationBar: widget.showNavBar
            ? BottomNavigationBar(
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor, // Theo Theme
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor, // Xanh hoặc Vàng
          unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 28,
          elevation: 10,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Chart'),
          ],
        )
            : null,
      ),
    );
  }
}