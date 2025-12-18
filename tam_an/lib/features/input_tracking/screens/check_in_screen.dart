import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/custom_app_bar.dart';
import 'check_in_overlay.dart';
import 'home_screen.dart'; 

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              children: [
                // --- NÚT BACK & TIÊU ĐỀ ---
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(
                      Icons.undo,
                      color: Colors.white70,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                    }
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'CHECK-IN',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(color: AppColors.primaryYellow, blurRadius: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bạn đang cảm thấy:',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 30),

                // --- GRID NÚT BẤM  ---
                GridView.count(
                  shrinkWrap: true, 
                  physics:
                      const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của Grid
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                  _buildMoodButton('VUI', AppColors.moodVui, context),
                  _buildMoodButton('BUỒN', AppColors.moodBuon, context),
                  _buildMoodButton('BÌNH THƯỜNG', AppColors.moodBinhThuong, context),
                  _buildMoodButton('GIẬN DỮ', AppColors.moodGianDu, context),
                  _buildMoodButton('HẠNH PHÚC', AppColors.moodHanhPhuc, context),
                  _buildMoodButton('CĂNG THẲNG', AppColors.moodCangThang, context),
                  ],
                ),

                const SizedBox(height: 40),

                // --- ICON TRANG TRÍ CUỐI ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallIcon(Icons.sentiment_very_dissatisfied),
                    _buildSmallIcon(Icons.sentiment_dissatisfied),
                    _buildSmallIcon(Icons.sentiment_neutral),
                    _buildSmallIcon(Icons.sentiment_satisfied),
                    _buildSmallIcon(Icons.sentiment_very_satisfied),
                    _buildSmallIcon(Icons.sentiment_very_satisfied_outlined),
                  ],
                ),

                // Thêm khoảng trống dưới cùng để không bị sát đáy quá
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
        // Hàm gọi Overlay Bottom Sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, 
          backgroundColor: Colors.transparent, 
          builder: (context) => const CheckInOverlay(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSmallIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Icon(icon, color: AppColors.primaryYellow, size: 20),
    );
  }
}
