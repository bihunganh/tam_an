import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'check_in_overlay.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  int _getMoodLevel(String moodText) {
    switch (moodText) {
      case 'HẠNH PHÚC': return 6;
      case 'VUI': return 5;
      case 'BÌNH THƯỜNG': return 4;
      case 'CĂNG THẲNG': return 3;
      case 'BUỒN': return 2;
      case 'GIẬN DỮ': return 1;
      default: return 4;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo Theme để sử dụng màu sắc động
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự động lấy trắng/đen
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                // Nút Back tự đổi màu theo IconTheme
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: theme.iconTheme.color, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                // Tiêu đề CHECK-IN (Xanh ở Light, Vàng ở Dark)
                Text(
                  'CHECK-IN',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Bạn đang cảm thấy:',
                  style: TextStyle(
                    color: primaryColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),

                // --- GRID NÚT BẤM ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildMoodButton('VUI', AppColors.moodFun, context),
                    _buildMoodButton('BUỒN', AppColors.moodSad, context),
                    _buildMoodButton('BÌNH THƯỜNG', AppColors.moodNeutral, context),
                    _buildMoodButton('GIẬN DỮ', AppColors.moodMad, context),
                    _buildMoodButton('HẠNH PHÚC', AppColors.moodHappy, context),
                    _buildMoodButton('CĂNG THẲNG', AppColors.moodAnxiety, context),
                  ],
                ),

                const SizedBox(height: 50),

                // --- DÃY ICON TRANG TRÍ ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallIcon(Icons.sentiment_very_dissatisfied, primaryColor),
                    _buildSmallIcon(Icons.sentiment_dissatisfied, primaryColor),
                    _buildSmallIcon(Icons.sentiment_neutral, primaryColor),
                    _buildSmallIcon(Icons.sentiment_satisfied, primaryColor),
                    _buildSmallIcon(Icons.sentiment_very_satisfied, primaryColor),
                    _buildSmallIcon(Icons.sentiment_very_satisfied_outlined, primaryColor),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(String text, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CheckInOverlay(
            moodLabel: text,
            moodLevel: _getMoodLevel(text),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white, // Giữ chữ trắng để tương phản tốt trên nút màu
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Icon(icon, color: color.withOpacity(0.5), size: 22),
    );
  }
}