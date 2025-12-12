import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../main_screen.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ĐÃ DỌN BỎKHOẢNG ---

              const Spacer(flex: 1), // Đẩy nội dung xuống giữa
              // 2. Lời chào
              const Text(
                'Xin chào, Bạn !',
                style: TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Hãy Check-in để tôi biết bạn\nđang cảm thấy thế nào',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  height: 1.5, // Khoảng cách dòng
                ),
              ),

              const Spacer(flex: 1),

              // 3. NÚT CHECK-IN KHỔNG LỒ (Phát sáng)
              GestureDetector(
                onTap: () {
                  // Điều hướng đến màn hình check-in với navbar
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(
                        showNavBar: true,
                        initialIndex: 0, // Bắt đầu ở tab Check-in
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 220, // Kích thước vòng tròn
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.buttonDark,
                    shape: BoxShape.circle,
                    // Hiệu ứng đổ bóng phát sáng (Glow)
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withOpacity(
                          0.15,
                        ), // Màu bóng mờ
                        blurRadius: 40, // Độ nhòe
                        spreadRadius: 5, // Độ lan tỏa
                      ),
                      // Viền mờ xung quanh để tạo độ nổi
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(4, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'CHECK-IN',
                    style: TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        // Đổ bóng cho chữ để tạo hiệu ứng Neon nhẹ
                        Shadow(color: AppColors.primaryYellow, blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // 4. Hàng Icon cảm xúc (Trang trí)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildEmojiIcon(Icons.sentiment_very_dissatisfied),
                  _buildEmojiIcon(Icons.sentiment_dissatisfied),
                  _buildEmojiIcon(Icons.sentiment_neutral),
                  _buildEmojiIcon(Icons.sentiment_satisfied),
                  _buildEmojiIcon(Icons.sentiment_very_satisfied),
                  _buildEmojiIcon(
                    Icons.sentiment_very_satisfied_outlined,
                  ), // Mặt cười toe toét
                ],
              ),

              const Spacer(flex: 2), // Khoảng trống dưới cùng lớn hơn
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để vẽ icon mặt cười cho gọn code
  static Widget _buildEmojiIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        icon,
        color: AppColors.primaryYellow, // Màu vàng
        size: 24, // Kích thước icon
      ),
    );
  }
}

