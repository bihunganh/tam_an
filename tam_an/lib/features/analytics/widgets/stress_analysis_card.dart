import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StressAnalysisCard extends StatelessWidget {
  final Map<String,int> negativeActivities;
  final Map<String,int> negativeLocations;
  final Map<String,int> negativeCompanions;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const StressAnalysisCard({Key? key, required this.negativeActivities, required this.negativeLocations, required this.negativeCompanions, required this.selectedCategory, required this.onCategoryChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, int> currentData = {};
    if (selectedCategory == 'Hành động') currentData = negativeActivities;
    if (selectedCategory == 'Địa điểm') currentData = negativeLocations;
    if (selectedCategory == 'Bạn bè') currentData = negativeCompanions;

    var sortedKeys = currentData.keys.toList()..sort((k1, k2) => currentData[k2]!.compareTo(currentData[k1]!));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nguyên nhân tiêu cực', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.5))
                ),
                child: DropdownButton<String>(
                  value: selectedCategory,
                  dropdownColor: const Color(0xFF383838),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.tune, color: AppColors.primaryBlue, size: 16),
                  style: const TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                  items: ['Hành động', 'Địa điểm', 'Bạn bè'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) onCategoryChanged(newValue);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          if (currentData.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Tuyệt vời! Không có dữ liệu tiêu cực cho mục này.", style: TextStyle(color: Colors.white30)),
            )
          else
            ...sortedKeys.map((key) {
              int val = currentData[key]!;
              int max = currentData.values.reduce((a, b) => a > b ? a : b);
              int percent = ((val / max) * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCategoryItem(key, percent, AppColors.moodMad),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int percentage, Color barColor) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF383838), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(height: 8, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 35, child: Text('$percentage%', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54, fontSize: 12))),
      ],
    );
  }
}
