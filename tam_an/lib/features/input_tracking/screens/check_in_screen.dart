import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import 'check_in_overlay.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Tạo hiệu ứng nhịp thở nhẹ nhàng cho toàn màn hình
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. NỀN NGHỆ THUẬT (BLOBS CHUYỂN ĐỘNG NHẸ)
          _buildBackgroundBlobs(theme),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: theme.iconTheme.color, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),

                    // TIÊU ĐỀ NGHỆ THUẬT
                    Text(
                      'Tâm trạng hiện tại',
                      style: TextStyle(
                        color: theme.textTheme.displayLarge?.color ?? Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lắng nghe cảm xúc của chính mình...',
                      style: TextStyle(
                        color: primaryColor.withOpacity(0.6),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 2. GRID CẢM XÚC PHONG CÁCH GLASSMORPHISM
                    _buildGlassMoodGrid(context, theme),

                    const SizedBox(height: 60),

                    // 3. CÂU QUOTE TRUYỀN CẢM HỨNG
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "“Mọi cảm xúc đều có giá trị.\nHãy ôm ấp lấy chúng.”",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.7),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET TRANG TRÍ NỀN ---
  Widget _buildBackgroundBlobs(ThemeData theme) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 100 + (_controller.value * 20),
              right: -50,
              child: _blob(300, theme.colorScheme.primary.withOpacity(0.1)),
            ),
            Positioned(
              bottom: 100 - (_controller.value * 30),
              left: -50,
              child: _blob(250, theme.colorScheme.secondary.withOpacity(0.08)),
            ),
          ],
        );
      },
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // --- GRID CẢM XÚC NÂNG CẤP ---
  Widget _buildGlassMoodGrid(BuildContext context, ThemeData theme) {
    final moods = [
      // Hạnh phúc: Tim hồng
      {'label': 'HẠNH PHÚC', 'color': AppColors.moodHappyPink, 'icon': Icons.favorite_rounded},
      // Vui: Ngôi sao năng lượng (Thay cho mặt người)
      {'label': 'VUI', 'color': AppColors.moodFun, 'icon': Icons.star_rounded},
      // Bình thường: Sự cân bằng (Thay cho mặt người)
      {'label': 'BÌNH THƯỜNG', 'color': AppColors.moodNeutral, 'icon': Icons.balance_rounded},
      // Căng thẳng: Giữ nguyên
      {'label': 'CĂNG THẲNG', 'color': AppColors.moodAnxiety, 'icon': Icons.psychology_rounded},
      // Buồn: Mây mưa (Thay cho đám mây cũ)
      {'label': 'BUỒN', 'color': AppColors.moodSadRain, 'icon': Icons.cloud_off_rounded},
      // Giận dữ: Giữ nguyên
      {'label': 'GIẬN DỮ', 'color': AppColors.moodMad, 'icon': Icons.local_fire_department_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        return _buildGlassCard(
          context,
          mood['label'] as String,
          mood['color'] as Color,
          mood['icon'] as IconData,
          theme,
        );
      },
    );
  }

  Widget _buildGlassCard(BuildContext context, String text, Color color, IconData icon, ThemeData theme) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(theme.brightness == Brightness.light ? 0.85 : 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}