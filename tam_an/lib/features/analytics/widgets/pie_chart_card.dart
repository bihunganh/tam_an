import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';

class PieChartCard extends StatelessWidget {
  final Map<int, int> moodCounts;
  const PieChartCard({Key? key, required this.moodCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = moodCounts.values.fold<int>(0, (p, e) => p + e);
    if (total == 0) return const SizedBox.shrink();

    List<PieChartSectionData> sections = [];
    sections.add(PieChartSectionData(color: AppColors.moodMad, value: (moodCounts[1] ?? 0).toDouble(), title: '', radius: 30));
    sections.add(PieChartSectionData(color: AppColors.moodSad, value: (moodCounts[2] ?? 0).toDouble(), title: '', radius: 30));
    sections.add(PieChartSectionData(color: AppColors.moodAnxiety, value: (moodCounts[3] ?? 0).toDouble(), title: '', radius: 30));
    sections.add(PieChartSectionData(color: AppColors.moodNeutral, value: (moodCounts[4] ?? 0).toDouble(), title: '', radius: 30));
    sections.add(PieChartSectionData(color: AppColors.moodFun, value: (moodCounts[5] ?? 0).toDouble(), title: '', radius: 30));
    sections.add(PieChartSectionData(color: AppColors.moodHappy, value: (moodCounts[6] ?? 0).toDouble(), title: '', radius: 30));

    Widget legendItem(int level, String label, Color color) {
      final count = moodCounts[level] ?? 0;
      if (count == 0) return const SizedBox.shrink();
      final percent = ((count / total) * 100).round();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text("$label ($percent%)", style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tỷ lệ cảm xúc', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeOutQuart,
                  builder: (context, value, child) {
                    return PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 45,
                        startDegreeOffset: 270 * value,
                        sections: sections,
                        borderData: FlBorderData(show: false),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    legendItem(6, "Hạnh phúc", AppColors.moodHappy),
                    legendItem(5, "Vui vẻ", AppColors.moodFun),
                    legendItem(4, "Bình thường", AppColors.moodNeutral),
                    legendItem(3, "Căng thẳng", AppColors.moodAnxiety),
                    legendItem(2, "Buồn", AppColors.moodSad),
                    legendItem(1, "Giận dữ", AppColors.moodMad),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
