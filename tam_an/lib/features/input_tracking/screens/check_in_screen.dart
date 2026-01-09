import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/user_provider.dart';
import 'check_in_overlay.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  // Ánh xạ mức độ cảm xúc
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

  // Ánh xạ Icon tương ứng cho Ảnh 2
  IconData _getMoodIcon(String moodText) {
    switch (moodText) {
      case 'HẠNH PHÚC': return Icons.wb_sunny_rounded;
      case 'VUI': return Icons.sentiment_very_satisfied_rounded;
      case 'BÌNH THƯỜNG': return Icons.sentiment_neutral_rounded;
      case 'CĂNG THẲNG': return Icons.psychology_rounded;
      case 'BUỒN': return Icons.cloud_rounded;
      case 'GIẬN DỮ': return Icons.local_fire_department_rounded;
      default: return Icons.sentiment_satisfied_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Provider.of<UserProvider>(context).user;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM HEADER (Tâm An + X + Avatar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tâm An",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  _buildUserAvatar(user),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nút X để quay lại
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 30),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ).animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Tiêu đề mới theo Ảnh 2
                    const Text(
                      'Tâm trạng hiện tại',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1),

                    const SizedBox(height: 8),

                    Text(
                      'Lắng nghe cảm xúc của chính mình...',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 35),

                    // --- GRID NÚT BẤM (Thiết kế Ảnh 2) ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.1, // Tạo hình ô vuông hơi chữ nhật đứng
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildMoodCard('HẠNH PHÚC', const Color(0xFF4CAF50), context),
                        _buildMoodCard('VUI', const Color(0xFFFFA000), context),
                        _buildMoodCard('BÌNH THƯỜNG', const Color(0xFF42A5F5), context),
                        _buildMoodCard('CĂNG THẲNG', const Color(0xFF9575CD), context),
                        _buildMoodCard('BUỒN', const Color(0xFFC2185B), context),
                        _buildMoodCard('GIẬN DỮ', const Color(0xFFD32F2F), context),
                      ],
                    ).animate().fadeIn(delay: 400.ms).scale(curve: Curves.easeOutBack),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ô cảm xúc theo Ảnh 2
  Widget _buildMoodCard(String text, Color color, BuildContext context) {
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              offset: const Offset(0, 8),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMoodIcon(text),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị Avatar góc trên
  Widget _buildUserAvatar(dynamic user) {
    if (user == null) return const SizedBox();
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey[300],
        backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ? (user.avatarUrl!.startsWith('http')
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : MemoryImage(base64Decode(user.avatarUrl!)) as ImageProvider)
            : null,
        child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
            ? Text(user.username[0].toUpperCase(), style: const TextStyle(fontSize: 12))
            : null,
      ),
    );
  }
}