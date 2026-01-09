import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/checkin_service.dart';
import '../../../data/models/checkin_model.dart';
import 'package:intl/intl.dart';

bool _localIsSameDay(DateTime a, DateTime? b) {
  if (b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class EmotionDonutChart extends StatefulWidget {
  final String? userId;
  final DateTime? selectedDay;

  const EmotionDonutChart({Key? key, required this.userId, required this.selectedDay}) : super(key: key);

  @override
  State<EmotionDonutChart> createState() => _EmotionDonutChartState();
}

class _EmotionDonutChartState extends State<EmotionDonutChart> {
  bool _isLoaded = false;
  final CheckInService _service = CheckInService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Tự động đổi Trắng/Xám đậm
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.selectedDay != null
                ? "Số cảm xúc ngày ${DateFormat('d/M').format(widget.selectedDay!)}"
                : "Số cảm xúc",
            style: TextStyle(
                color: theme.textTheme.titleMedium?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 160,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _isLoaded ? 1 : 0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return StreamBuilder<List<CheckInModel>>(
                        stream: widget.userId == null ? const Stream.empty() : _service.getCheckInHistory(widget.userId!),
                        builder: (context, snapshot) {
                          final sections = _computeSections(snapshot.data ?? [], widget.selectedDay);
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 50,
                              startDegreeOffset: 270 * value,
                              sections: sections,
                              borderData: FlBorderData(show: false),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(AppColors.moodMad, "Tức giận", theme),
                    _buildLegendItem(AppColors.moodSad, "Buồn", theme),
                    _buildLegendItem(AppColors.moodAnxiety, "Căng thẳng", theme),
                    _buildLegendItem(AppColors.moodNeutral, "Bình thường", theme),
                    _buildLegendItem(AppColors.moodFun, "Vui vẻ", theme),
                    _buildLegendItem(AppColors.moodHappy, "Hạnh phúc", theme),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _computeSections(List<CheckInModel> all, DateTime? selectedDay) {
    final counts = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (final item in all) {
      if (selectedDay == null || _localIsSameDay(item.timestamp, selectedDay)) {
        counts[item.moodLevel] = (counts[item.moodLevel] ?? 0) + 1;
      }
    }
    final total = counts.values.fold<double>(0, (p, e) => p + e);
    if (total == 0) return [PieChartSectionData(color: Colors.grey.withOpacity(0.1), value: 1, title: '', radius: 25)];

    return [
      PieChartSectionData(color: AppColors.moodMad, value: counts[1] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodSad, value: counts[2] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodAnxiety, value: counts[3] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodNeutral, value: counts[4] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodFun, value: counts[5] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodHappy, value: counts[6] ?? 0, title: '', radius: 25),
    ];
  }
}

class DailyEmotionSummary extends StatefulWidget {
  final String? userId;
  final DateTime? selectedDay;

  const DailyEmotionSummary({Key? key, required this.userId, required this.selectedDay}) : super(key: key);

  @override
  State<DailyEmotionSummary> createState() => _DailyEmotionSummaryState();
}

class _MoodItem {
  final String name;
  final IconData icon;
  final Color color;
  _MoodItem(this.name, this.icon, this.color);
}

class _DailyEmotionSummaryState extends State<DailyEmotionSummary> {
  late PageController _pageController;
  // Thay đổi: Mặc định là index 3 (Bình thường) hoặc tạo index riêng cho "Chưa có dữ liệu"
  int _currentPage = 3; 

  final List<_MoodItem> _moods = [
    _MoodItem("Buồn", Icons.sentiment_very_dissatisfied, AppColors.moodSad),
    _MoodItem("Căng thẳng", Icons.sentiment_dissatisfied, AppColors.moodAnxiety),
    _MoodItem("Tức giận", Icons.sentiment_very_dissatisfied_outlined, AppColors.moodMad),
    _MoodItem("Bình thường", Icons.sentiment_neutral, AppColors.moodNeutral),
    _MoodItem("Vui vẻ", Icons.sentiment_satisfied_alt, AppColors.moodFun),
  ];

  final CheckInService _service = CheckInService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.selectedDay != null
                    ? "Tổng kết cảm xúc cuối ngày ${DateFormat('d/M').format(widget.selectedDay!)}"
                    : "Tổng kết cảm xúc cuối ngày",
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleMedium?.color
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 120,
            child: StreamBuilder<List<CheckInModel>>(
              stream: widget.userId == null ? const Stream.empty() : _service.getCheckInHistory(widget.userId!),
              builder: (context, snapshot) {
                final daily = (snapshot.data ?? []).where((c) => _localIsSameDay(c.timestamp, widget.selectedDay)).toList();

                // Logic xử lý khi có dữ liệu
                if (daily.isNotEmpty) {
                  final freq = <int, int>{};
                  for (final c in daily) {
                    freq[c.moodLevel] = (freq[c.moodLevel] ?? 0) + 1;
                  }
                  int dominant = daily.last.moodLevel;
                  int bestCount = 0;
                  freq.forEach((k, v) {
                    if (v > bestCount) {
                      bestCount = v;
                      dominant = k;
                    }
                  });
                  int indexOfMood = _levelToIndex(dominant);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (_currentPage != indexOfMood) {
                      _pageController.animateToPage(indexOfMood, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                      setState(() => _currentPage = indexOfMood);
                    }
                  });
                } else {
                   // Logic xử lý khi KHÔNG có dữ liệu: Đặt về "Bình thường" (index 3)
                   WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    if (_currentPage != 3) {
                       _pageController.jumpToPage(3); // Hoặc animateToPage
                       setState(() => _currentPage = 3);
                    }
                  });
                }

                // Nếu không có dữ liệu, hiển thị thông báo thay vì PageView (Tùy chọn)
                if (daily.isEmpty) {
                    return Center(
                        child: Text(
                            "Chưa có dữ liệu",
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                        ),
                    );
                }

                return PageView.builder(
                  controller: _pageController,
                  itemCount: _moods.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = (_pageController.page! - index).abs();
                          value = (1 - (value * 0.5)).clamp(0.0, 1.0);
                        } else {
                          value = (index == _currentPage) ? 1.0 : 0.5;
                        }

                        final double scale = Curves.easeOut.transform(value) * 1.35;
                        final isSelected = (index == _currentPage);
                        final mood = _moods[index];

                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? mood.color
                                    : (isDark ? const Color(0xFF484848) : Colors.grey[200]),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: mood.color.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)]
                                    : [],
                              ),
                              child: Icon(
                                mood.icon,
                                color: isSelected
                                    ? (isDark ? const Color(0xFF1C1C1E) : Colors.white)
                                    : (isDark ? Colors.grey[400] : Colors.grey[500]),
                                size: 36,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          // Chỉ hiển thị tên cảm xúc khi có dữ liệu check-in (hoặc xử lý hiển thị khác)
           StreamBuilder<List<CheckInModel>>(
              stream: widget.userId == null ? const Stream.empty() : _service.getCheckInHistory(widget.userId!),
              builder: (context, snapshot) {
                  final daily = (snapshot.data ?? []).where((c) => _localIsSameDay(c.timestamp, widget.selectedDay)).toList();
                  if (daily.isEmpty) return const SizedBox.shrink(); // Ẩn tên nếu chưa có dữ liệu

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _moods[_currentPage].name,
                      key: ValueKey<int>(_currentPage),
                      style: TextStyle(
                        color: _moods[_currentPage].color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
              }
           ),
        ],
      ),
    );
  }

  int _levelToIndex(int level) {
    if (level == 6 || level == 5) return 4;
    if (level == 4) return 3;
    if (level == 3) return 1;
    if (level == 2) return 0;
    return 2;
  }
}