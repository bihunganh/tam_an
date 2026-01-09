import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StressAnalysisCard extends StatelessWidget {
  final Map<String, int> negativeActivities;
  final Map<String, int> negativeLocations;
  final Map<String, int> negativeCompanions;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const StressAnalysisCard({
    Key? key,
    required this.negativeActivities,
    required this.negativeLocations,
    required this.negativeCompanions,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Map<String, int> currentData = {};
    if (selectedCategory == 'Hành động') currentData = negativeActivities;
    if (selectedCategory == 'Địa điểm') currentData = negativeLocations;
    if (selectedCategory == 'Bạn bè') currentData = negativeCompanions;

    var sortedKeys = currentData.keys.toList()
      ..sort((k1, k2) => currentData[k2]!.compareTo(currentData[k1]!));

    return Container(
      width: double.infinity,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nguyên nhân tiêu cực',
                style: TextStyle(
                  color: theme.textTheme.titleMedium?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Dropdown Menu Tối ưu hóa
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(Icons.tune, color: theme.colorScheme.primary, size: 16),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    items: ['Hành động', 'Địa điểm', 'Bạn bè'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) onCategoryChanged(newValue);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (currentData.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  "Tuyệt vời! Không có dữ liệu tiêu cực.",
                  style: TextStyle(color: theme.disabledColor, fontSize: 13),
                ),
              ),
            )
          else
            ...sortedKeys.map((key) {
              int val = currentData[key]!;
              int max = currentData.values.reduce((a, b) => a > b ? a : b);
              int percent = ((val / max) * 100).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildCategoryItem(key, percent, AppColors.moodMad, theme),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int percentage, Color barColor, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            category,
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Rãnh (Track) của thanh tiến trình
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Phần trăm thực tế (Fill)
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: barColor.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      if (percentage > 5)
                        BoxShadow(
                          color: barColor.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}