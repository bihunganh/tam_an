import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../data/models/user_model.dart';
import '../../../../main_screen.dart';
import '../../auth_system/screens/sign_in.dart';

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
          // --- 1. LOGIC HIỂN THỊ TEXT CHÀO MỪNG ---
          Text(
            currentUser == null
                ? "Chào bạn,"
                : "Chào ${currentUser!.username},",
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

          const SizedBox(height: 30),

          // --- 2. NÚT CHECK-IN
          InkWell(
              onTap: () {
                // LOGIC KIỂM TRA ĐĂNG NHẬP (Đã sửa lỗi crash)
                if (currentUser == null) {
                  // Nếu chưa đăng nhập -> Chuyển thẳng sang màn hình Login
                  // Không hiện SnackBar ở đây để tránh lỗi "Unsafe Context"
                  AppRouter.push(context, const LoginScreen());
                } else {
                  // Nếu đã đăng nhập -> Vào Check-in bình thường
                  AppRouter.push(context, const MainScreen(showNavBar: true));
                }
            },
            borderRadius: BorderRadius.circular(110),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardColor,
                boxShadow: [
                  // Tạo viền cứng màu xanh chỉ ở phía dưới
                  BoxShadow(
                    color: AppColors.primaryBlue,
                    offset: const Offset(0, 5), // Đẩy bóng xuống dưới 6px
                    blurRadius: 0, // Không làm mờ -> Tạo nét cứng
                    spreadRadius: 0,
                  ),
                ],

                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  "CHECK-IN",
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 32, // Chữ to hơn
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    // Đã bỏ shadows (glow) của chữ
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // --- 3. CÁC ICON CẢM XÚC ---
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
        color: AppColors.primaryBlue.withOpacity(0.7), // Giảm độ sáng icon phụ một chút cho nút chính nổi bật
        size: 28,
      ),
    );
  }
}