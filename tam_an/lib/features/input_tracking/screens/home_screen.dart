import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/user_model.dart'; // Import Model
import '../../../../main_screen.dart';

class HomeScreen extends StatelessWidget {
  // Nhận biến user từ MainScreen truyền xuống
  final UserModel? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- LOGIC HIỂN THỊ TEXT CHÀO MỪNG (ĐÃ SỬA) ---
          // Thay đổi nội dung dựa vào việc user đã đăng nhập hay chưa
          Text(
            currentUser == null 
                ? "Chào bạn,"                 // Chưa đăng nhập
                : "Chào ${currentUser!.username},", // Đã đăng nhập
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            "Hôm nay bạn cảm thấy thế nào?",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
          
          const SizedBox(height: 40), // Khoảng cách đến nút Check-in
          
          // --- NÚT CHECK-IN ---
          GestureDetector(
            onTap: () {
              // Chuyển sang giao diện Check-in (có Navbar)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen(showNavBar: true),
                ),
              );
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryYellow.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 5,
                  )
                ],
                border: Border.all(
                  color: AppColors.primaryYellow.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text(
                  "CHECK-IN",
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: AppColors.primaryYellow,
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Các icon cảm xúc bên dưới
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallIcon(Icons.sentiment_very_dissatisfied),
              _buildSmallIcon(Icons.sentiment_dissatisfied),
              _buildSmallIcon(Icons.sentiment_neutral),
              _buildSmallIcon(Icons.sentiment_satisfied),
              _buildSmallIcon(Icons.sentiment_very_satisfied),
              _buildSmallIcon(Icons.sentiment_very_satisfied_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        icon,
        color: AppColors.primaryYellow,
        size: 30,
      ),
    );
  }
}