import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';

// Import các màn hình con
import 'features/input_tracking/screens/history_screen.dart';
import 'features/input_tracking/screens/check_in_screen.dart';
import 'features/input_tracking/screens/home_screen.dart';
//import 'features/analytics/screens/analysis_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Biến lưu chỉ số tab đang chọn (0: Home, 1: Calendar, 2: Chart)
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng
  // Lưu ý: Các màn hình con CẦN BỎ BottomNavigationBar đi nhé
  // (Chúng ta sẽ dùng BottomNavigationBar chung ở MainScreen này)
  final List<Widget> _screens = [
    const HomeScreen(), // Tab 0: Home
    const HistoryScreen(), // Tab 1: History
    const Scaffold(body: Center(child: Text("Chart"))), // Tab 2
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
