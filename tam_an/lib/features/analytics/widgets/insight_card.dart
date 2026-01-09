import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class InsightCard extends StatelessWidget {
  final List<String> insights;
  const InsightCard({Key? key, required this.insights}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Tăng padding để thoáng hơn
      decoration: BoxDecoration(
        // Màu nền: Dùng Primary pha cực loãng ở chế độ Sáng để tạo cảm giác "AI"
        color: isDark
            ? const Color(0xFF2C3E50).withOpacity(0.8)
            : primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(isDark ? 0.3 : 0.1),
          width: 1,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon lấp lánh (Dùng màu Amber đặc trưng của AI/Insight)
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
              const SizedBox(width: 12),
              Text(
                'Góc nhìn Tâm An (AI)',
                style: TextStyle(
                  color: isDark ? Colors.amberAccent : Colors.amber[800],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: primaryColor.withOpacity(0.1),
              height: 1,
            ),
          ),

          ...insights.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bullet point dùng màu chủ đạo của Theme
                Text(
                    "• ",
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    text.replaceAll('**', ''),
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.9),
                      fontSize: 14,
                      height: 1.6, // Tăng khoảng cách dòng cho dễ đọc
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}