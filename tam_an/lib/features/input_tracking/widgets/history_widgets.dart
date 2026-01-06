import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/checkin_service.dart';
import '../../../data/models/checkin_model.dart';
import 'package:intl/intl.dart';

// Helper used by widgets in this file to compare dates
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
    // Trigger animation sau khi build xong
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor, // use card style to match other cards
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
            widget.selectedDay != null
              ? "Số cảm xúc ngày ${DateFormat('d/M').format(widget.selectedDay!)}"
              : "Số cảm xúc",
            style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              // --- PHẦN CHART ---
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 160,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: _isLoaded ? 1 : 0),
                    duration: const Duration(seconds: 2), // Xoay trong 2 giây
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return StreamBuilder<List<CheckInModel>>(
                        stream: widget.userId == null ? const Stream.empty() : _service.getCheckInHistory(widget.userId!),
                        builder: (context, snapshot) {
                          // compute sections based on snapshot
                          final sections = _computeSections(snapshot.data ?? [], widget.selectedDay);
                          return PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 50,
                              startDegreeOffset: 270 * value, // Xoay chart
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
              // --- PHẦN CHÚ THÍCH (LEGEND) ---
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(AppColors.moodMad, "Tức giận"),
                    _buildLegendItem(AppColors.moodSad, "Buồn"),
                    _buildLegendItem(AppColors.moodAnxiety, "Lo âu"), // Dùng moodAnxiety cho Căng thẳng
                    _buildLegendItem(AppColors.moodNeutral, "Bình thường"),
                    _buildLegendItem(AppColors.moodFun, "Vui vẻ"),
                    _buildLegendItem(AppColors.moodHappy, "Hạnh phúc"),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Helper tạo chú thích
  Widget _buildLegendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _computeSections(List<CheckInModel> all, DateTime? selectedDay) {
    // Initialize counts for levels 1..6 mapping to moods
    final counts = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (final item in all) {
      if (selectedDay == null || _localIsSameDay(item.timestamp, selectedDay)) {
        final level = item.moodLevel;
        counts[level] = (counts[level] ?? 0) + 1;
      }
    }

    final total = counts.values.fold<double>(0, (p, e) => p + e);
    if (total == 0) {
      // return subtle empty sections so chart still renders
      return [
        PieChartSectionData(color: AppColors.moodMad.withOpacity(0.12), value: 1, title: '', radius: 25),
      ];
    }

    return [
      PieChartSectionData(color: AppColors.moodMad, value: counts[1] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodSad, value: counts[2] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodAnxiety, value: counts[3] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodNeutral, value: counts[4] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodFun, value: counts[5] ?? 0, title: '', radius: 25),
      PieChartSectionData(color: AppColors.moodHappy, value: counts[6] ?? 0, title: '', radius: 25),
    ];
  }

  bool isSameDay(DateTime a, DateTime? b) {
    if (b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}


class DailyEmotionSummary extends StatefulWidget {
  final String? userId;
  final DateTime? selectedDay;

  const DailyEmotionSummary({Key? key, required this.userId, required this.selectedDay}) : super(key: key);

  @override
  State<DailyEmotionSummary> createState() => _DailyEmotionSummaryState();
}

// Model đơn giản để map dữ liệu
class _MoodItem {
  final String name;
  final IconData icon;
  final Color color;
  _MoodItem(this.name, this.icon, this.color);
}

class _DailyEmotionSummaryState extends State<DailyEmotionSummary> {
  late PageController _pageController;
  int _currentPage = 2; // Mặc định chọn icon ở giữa

  // Danh sách các cảm xúc map với AppColors
  final List<_MoodItem> _moods = [
    _MoodItem("Buồn", Icons.sentiment_very_dissatisfied, AppColors.moodSad),
    _MoodItem("Lo âu", Icons.sentiment_dissatisfied, AppColors.moodAnxiety),
    _MoodItem("Tức giận", Icons.sentiment_very_dissatisfied_outlined, AppColors.moodMad), // Main mood
    _MoodItem("Bình thường", Icons.sentiment_neutral, AppColors.moodNeutral),
    _MoodItem("Vui vẻ", Icons.sentiment_satisfied_alt, AppColors.moodFun),
  ];

  final CheckInService _service = CheckInService();

  @override
  void initState() {
    super.initState();
    // viewportFraction 0.3 để các icon xích lại gần nhau hơn giống ảnh
    _pageController = PageController(initialPage: _currentPage, viewportFraction: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(vertical: 24), // Tăng padding để shadow không bị cắt
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Tiêu đề aligned left and larger
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.selectedDay != null
                    ? "Tổng kết cảm xúc cuối ngày ${DateFormat('d/M').format(widget.selectedDay!)}"
                    : "Tổng kết cảm xúc cuối ngày",
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // --- SLIDER ICON / Carousel summary ---
          SizedBox(
            height: 120, // Chiều cao khu vực chứa icon
            child: StreamBuilder<List<CheckInModel>>(
              stream: widget.userId == null ? const Stream.empty() : _service.getCheckInHistory(widget.userId!),
              builder: (context, snapshot) {
                // ... (Logic xử lý dữ liệu giữ nguyên như cũ) ...
                final daily = (snapshot.data ?? []).where((c) => _localIsSameDay(c.timestamp, widget.selectedDay)).toList();
                
                // Logic tìm cảm xúc chủ đạo (giữ nguyên)
                int indexOfMood = 2; // Mặc định
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
                    indexOfMood = _levelToIndex(dominant);
                    
                    // Sync controller (giữ nguyên)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      if (_pageController.hasClients && (_pageController.page?.round() ?? _pageController.initialPage) != indexOfMood) {
                         // Chỉ animate nếu khác biệt để tránh loop
                         if (_currentPage != indexOfMood) {
                            _pageController.animateToPage(indexOfMood, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                            setState(() => _currentPage = indexOfMood);
                         }
                      }
                    });
                }
                // ... Hết logic xử lý dữ liệu ...

                return PageView.builder(
                  controller: _pageController,
                  itemCount: _moods.length,
                  physics: const BouncingScrollPhysics(), // Hiệu ứng lướt mượt
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double value = 1.0;
                        if (_pageController.position.haveDimensions) {
                          value = _pageController.page! - index;
                          value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                        } else {
                          value = (index == _currentPage) ? 1.0 : 0.5;
                        }

                        // Tính toán scale: Item giữa to hẳn (1.0 -> 1.2), item cạnh nhỏ (0.5 -> 0.8)
                        final double scale = Curves.easeOut.transform(value) * 1.35; 
                        final isSelected = (index == _currentPage);
                        final mood = _moods[index];

                        return Center(
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 70, 
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // SỬA ĐỔI 1: Màu nền
                                // Nếu chọn: Màu cảm xúc rực rỡ
                                // Nếu không chọn: Màu xám đậm (Grey[800]) giống trong ảnh
                                color: isSelected ? mood.color : const Color(0xFF484848), 
                                
                                // SỬA ĐỔI 2: Đổ bóng (Glow)
                                // Chỉ item được chọn mới có bóng màu đậm
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: mood.color.withOpacity(0.6), // Bóng màu đậm hơn
                                          blurRadius: 10, // Độ nhòe lớn tạo hiệu ứng glow
                                          spreadRadius: 1,
                                          offset: const Offset(0, 0),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Icon(
                                mood.icon,
                                // SỬA ĐỔI 3: Màu Icon
                                // Chọn: Màu tối (đen/xám đậm) để nổi trên nền màu
                                // Không chọn: Màu xám nhạt trung tính
                                color: isSelected ? const Color(0xFF1C1C1E) : Colors.grey[400], 
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

          // Tên cảm xúc bên dưới
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                child: child,
              ));
            },
            child: Text(
              _moods[_currentPage].name,
              key: ValueKey<int>(_currentPage),
              style: TextStyle(
                color: _moods[_currentPage].color, // Text màu theo cảm xúc
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _levelToIndex(int level) {
    if (level == 6) return 4;
    if (level == 5) return 4;
    if (level == 4) return 3;
    if (level == 3) return 1;
    if (level == 2) return 0;
    return 2;
  }
}