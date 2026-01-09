import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class PieChartCard extends StatelessWidget {
  final Map<int, int> moodCounts;
  const PieChartCard({Key? key, required this.moodCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total = moodCounts.values.fold<int>(0, (p, e) => p + e);
    if (total == 0) return const SizedBox.shrink();

    // Tạo danh sách các mảng màu với đường viền tinh tế
    List<PieChartSectionData> sections = [
      _buildSection(AppColors.moodMad, (moodCounts[1] ?? 0).toDouble(), theme),
      _buildSection(AppColors.moodSad, (moodCounts[2] ?? 0).toDouble(), theme),
      _buildSection(AppColors.moodAnxiety, (moodCounts[3] ?? 0).toDouble(), theme),
      _buildSection(AppColors.moodNeutral, (moodCounts[4] ?? 0).toDouble(), theme),
      _buildSection(AppColors.moodFun, (moodCounts[5] ?? 0).toDouble(), theme),
      _buildSection(AppColors.moodHappy, (moodCounts[6] ?? 0).toDouble(), theme),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: isDark ? null : Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Tỷ lệ cảm xúc',
              style: TextStyle(
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
              )
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              // BIỂU ĐỒ DONUT
              SizedBox(
                width: 140,
                height: 140,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutExpo,
                  builder: (context, value, child) {
                    return PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 42, // Tăng nhẹ để trông thanh thoát hơn
                        startDegreeOffset: 270 * value,
                        sections: sections,
                        borderData: FlBorderData(show: false),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 24),

              // CHÚ THÍCH (LEGEND)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(6, "Hạnh phúc", AppColors.moodHappy, total, theme),
                    _buildLegendItem(5, "Vui vẻ", AppColors.moodFun, total, theme),
                    _buildLegendItem(4, "Bình thường", AppColors.moodNeutral, total, theme),
                    _buildLegendItem(3, "Căng thẳng", AppColors.moodAnxiety, total, theme),
                    _buildLegendItem(2, "Buồn", AppColors.moodSad, total, theme),
                    _buildLegendItem(1, "Giận dữ", AppColors.moodMad, total, theme),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // Hàm xây dựng từng miếng bánh với viền mờ
  PieChartSectionData _buildSection(Color color, double value, ThemeData theme) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '',
      radius: 28,
      // Thêm viền trùng màu nền để tạo khoảng cách sạch sẽ giữa các mảng
      borderSide: BorderSide(color: theme.colorScheme.surface, width: 2),
    );
  }

  // Hàm xây dựng chú thích động
  Widget _buildLegendItem(int level, String label, Color color, int total, ThemeData theme) {
    final count = moodCounts[level] ?? 0;
    if (count == 0) return const SizedBox.shrink();
    final percent = ((count / total) * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              "$label",
              style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
              "$percent%",
              style: TextStyle(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold
              )
          ),
        ],
      ),
    );
  }
}