import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../data/models/user_model.dart';
import '../../../../main_screen.dart';
import '../../auth_system/screens/sign_in.dart';

class HomeScreen extends StatelessWidget {
  final UserModel? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy thông tin Theme hiện tại
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; // Sẽ là Xanh (Sáng) hoặc Vàng (Tối)

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- VĂN BẢN CHÀO MỪNG (Tự đổi màu theo Theme) ---
          Text(
            currentUser == null
                ? "Chào bạn,"
                : "Chào ${currentUser!.username},",
            style: TextStyle(
              color: theme.textTheme.headlineMedium?.color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Hôm nay bạn cảm thấy thế nào?",
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          // --- NÚT CHECK-IN KHỔNG LỒ ---
          InkWell(
            onTap: () {
              if (currentUser == null) {
                AppRouter.push(context, const LoginScreen());
              } else {
                AppRouter.push(context, const MainScreen(showNavBar: true));
              }
            },
            borderRadius: BorderRadius.circular(130),
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surface, // Màu nền nút tự đổi
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    offset: const Offset(0, 6), // Đổ bóng xuống dưới
                    blurRadius: 12, // Tạo hiệu ứng phát sáng nhẹ
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: primaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  "CHECK-IN",
                  style: TextStyle(
                    color: primaryColor, // Chữ Xanh hoặc Vàng
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // --- CÁC ICON CẢM XÚC PHÍA DƯỚI ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSmallIcon(Icons.sentiment_very_dissatisfied, primaryColor),
              _buildSmallIcon(Icons.sentiment_dissatisfied, primaryColor),
              _buildSmallIcon(Icons.sentiment_neutral, primaryColor),
              _buildSmallIcon(Icons.sentiment_satisfied, primaryColor),
              _buildSmallIcon(Icons.sentiment_very_satisfied, primaryColor),
              _buildSmallIcon(Icons.sentiment_very_satisfied_rounded, primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        icon,
        color: color.withOpacity(0.4), // Màu icon mờ hơn nút chính
        size: 28,
      ),
    );
  }
}