import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart'; // Import bộ icon
import '../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Biến để lưu tab hiện tại (0: Home, 1: History, 2: Report)
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. HEADER (AppBar)
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tâm An",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              "Thứ Bảy, 06 tháng 12", // Sau này sẽ code tự động lấy ngày
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Avatar nhỏ góc phải
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(PhosphorIcons.user(), color: Colors.white),
            ),
          )
        ],
      ),

      // 2. BODY (Nội dung chính)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút Check-in to đùng
            GestureDetector(
              onTap: () {
                // Tạm thời in ra log để biết nút hoạt động
                print("Bấm nút Check-in!");
                // BƯỚC SAU: Sẽ code hiện Bottom Sheet ở đây
              },
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surface, // Màu xám đen
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.smiley(), size: 48, color: AppColors.textPrimary),
                    const SizedBox(height: 8),
                    const Text(
                      "Check-in",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Bạn đang cảm thấy thế nào?",
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),

      // 3. BOTTOM NAVIGATION BAR (Thanh menu dưới)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface, // Màu nền thanh menu
        selectedItemColor: AppColors.accent, // Màu khi được chọn (Teal)
        unselectedItemColor: AppColors.textSecondary, // Màu khi chưa chọn
        showSelectedLabels: false, // Ẩn chữ, chỉ hiện icon cho Minimalist
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.house()),
            activeIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.calendarBlank()),
            activeIcon: Icon(PhosphorIcons.calendarBlank(PhosphorIconsStyle.fill)),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIcons.chartBar()),
            activeIcon: Icon(PhosphorIcons.chartBar(PhosphorIconsStyle.fill)),
            label: 'Insights',
          ),
        ],
      ),
    );
  }
}