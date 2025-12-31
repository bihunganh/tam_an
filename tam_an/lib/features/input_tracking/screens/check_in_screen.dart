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
    return Container(
      color: AppColors.background, // Màu nền
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 20.0,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft, // Hoặc center tùy bạn
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 28),
                  onPressed: () {
                    // Quay về HomeScreen
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 0),

              const Text(
                'CHECK-IN',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn đang cảm thấy:',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),

              // --- GRID NÚT BẤM (Giữ nguyên) ---
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

              const SizedBox(height: 40),

              // --- ICON TRANG TRÍ (Giữ nguyên) ---
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

              const SizedBox(height: 20),
            ],
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
      child: Icon(icon, color: AppColors.primaryBlue, size: 20),
    );
  }
}