import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'core/providers/user_provider.dart';
import 'features/user_profile/screens/profile_screen.dart';
import 'features/auth_system/screens/sign_in.dart';
import 'features/input_tracking/widgets/custom_app_bar.dart'; // Import Appbar
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

  // Danh sách các màn hình
  // Lưu ý: Ta chuyển _screens thành hàm getter hoặc build trong build() để truyền currentUser
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Show login success notification if requested
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
            margin: const EdgeInsets.all(10),
          ),
        );
      });
    }
  }


  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF303030),
        title: const Text("Đăng xuất", style: TextStyle(color: AppColors.primaryBlue)),
        content: const Text("Bạn có chắc chắn muốn đăng xuất không?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 1. Đóng dialog

              // 2. Gọi Firebase SignOut
              await _authService.signOut();

              if (mounted) {
                // 3. XÓA DỮ LIỆU USER TRONG RAM (Để fix lỗi hiện thông tin cũ)
                Provider.of<UserProvider>(context, listen: false).clear();

                // 4. Chuyển về màn hình đăng nhập
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

  // --- HÀM TẠO ICON USER CHO APPBAR ---
  Widget? _buildUserIcon() {
    // TRƯỜNG HỢP 1: Chưa đăng nhập -> Hiện Icon User cũ (Click vào để login)
    final user = Provider.of<UserProvider>(context).user;
    if (user == null) return null;

    // TRƯỜNG HỢP 2: Đã đăng nhập -> Hiện Avatar Menu (Slide down)
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
              // smooth push
              AppRouter.push(context, ProfileScreen(user: user));
        } else if (value == 'logout') {
          _handleLogout();
        }
      },
      color: const Color(0xFF353535),
      offset: const Offset(0, 50),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(children: [Icon(Icons.person, color: AppColors.primaryBlue), SizedBox(width: 10), Text("Hồ sơ cá nhân", style: TextStyle(color: Colors.white))]),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(children: [Icon(Icons.logout, color: Colors.redAccent), SizedBox(width: 10), Text("Đăng xuất", style: TextStyle(color: Colors.white))]),
        ),
      ],
      // Icon đại diện
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue, width: 2),
        ),
        child: CircleAvatar(
          radius: 16, // Nhỏ gọn vừa AppBar
          backgroundColor: Colors.grey[800],
          backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? (user.avatarUrl!.startsWith('http')
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : MemoryImage(base64Decode(user.avatarUrl!)))
              : null,
          child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
              ? Text(
                  user.username[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                )
              : null,
        ),
      ),
    );
  }

  // Xây dựng màn hình hiện tại
  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        // HomeScreen: pass current user from provider
        final user = Provider.of<UserProvider>(context).user;
        if (!widget.showNavBar) return HomeScreen(currentUser: user);
        return const CheckInScreen();
      case 1:
        return const HistoryScreen();
      case 2:
        return const AnalysisScreen();
      default:
        final user = Provider.of<UserProvider>(context).user;
        return HomeScreen(currentUser: user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Nếu không phải tab Check-in, quay về tab Check-in
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return false;
        }
        // Nếu đang ở tab Check-in -> Cho phép thoát màn hình này để về HomeScreen
        return true; 
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                backgroundColor: const Color(0xFF2B2B2B),
                selectedItemColor: AppColors.primaryBlue,
                unselectedItemColor: Colors.white70,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                iconSize: 28,
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
