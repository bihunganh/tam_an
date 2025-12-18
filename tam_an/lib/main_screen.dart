import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';

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
  // Biến lưu chỉ số tab đang chọn (0: Check-in, 1: History, 2: Chart)
  late int _selectedIndex;

  // Danh sách các màn hình tương ứng
  // Lưu ý: Các màn hình con CẦN BỎ BottomNavigationBar đi nhé
  // (Chúng ta sẽ dùng BottomNavigationBar chung ở MainScreen này)
  final List<Widget> _screens = [
    const CheckInScreen(), // Tab 0: Check-in (là "Home" trong navbar)
    const HistoryScreen(), // Tab 1: History
    const AnalysisScreen(), // Tab 2: Analysis/Statistics
  ];

  @override
  void initState() {
    super.initState();

    if (widget.showLoginSuccess) {
      // Dùng addPostFrameCallback để đảm bảo giao diện vẽ xong mới hiện thông báo
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
            backgroundColor: Colors.green, // Màu xanh lá báo thành công
            behavior: SnackBarBehavior.floating, // Nổi lên cho đẹp
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
          ),
        );
      });
    }
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nếu không hiện navbar (home screen), chỉ hiện Home Screen
    if (!widget.showNavBar) {
      return const HomeScreen();
    }

    // Nếu hiện navbar (sau khi check-in), hiện Check-in screen với navbar
    return WillPopScope(
      onWillPop: () async {
        // Khi nhấn back trên màn hình check-in, quay về home screen
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false; // Không pop, chỉ quay về tab check-in
        }
        // Nếu đang ở check-in và nhấn back, quay về home screen (không navbar)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(showNavBar: false),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,

        // Hiển thị màn hình tương ứng với index đang chọn
        // IndexedStack giúp giữ trạng thái màn hình (không bị load lại khi chuyển tab)
        body: IndexedStack(index: _selectedIndex, children: _screens),

        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF2B2B2B),
          selectedItemColor: AppColors.primaryYellow, // Màu vàng khi được chọn
          unselectedItemColor: Colors.white70, // Màu trắng mờ khi không chọn
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 28,
          currentIndex:
              _selectedIndex, // Quan trọng: Highlight icon đúng theo index
          onTap: _onItemTapped, // Quan trọng: Xử lý sự kiện bấm
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Chart',
            ),
          ],
        ),
      ),
    );
  }
}
